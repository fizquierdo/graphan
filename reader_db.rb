#encoding: UTF-8

require 'yaml'
require 'neography'
require 'chinese_pinyin' 

class GraphanServer
	def initialize
		cfg = YAML::load_file("config.yml")
		@neo = Neography::Rest.new("#{cfg["db"]["url"]}:#{cfg["db"]["port"]}")
	end

	# Readers
	def words
		# Return all nodes with label Word
		cypher = "MATCH (n:Word) 
							RETURN n"
		data = run_query(cypher)
		data
	end

	def words_selection(username, relationship)
		cypher = "MATCH (u:Person {name:'#{username}'})-[:#{relationship}]->(w:Word) 
		          RETURN w"
		data = run_query(cypher)
		data
	end
	def add_known_relationship(username, simp)
		cypher = "MATCH (:Person {name:'#{username}'})-[r:LEARNS]->(w:Word{simp:'#{simp}'}) 
		          DELETE r"
		data = run_query(cypher)
		cypher = "MATCH (u:Person {name:'#{username}'}), (w:Word {simp:'#{simp}'})
							CREATE (u)-[:KNOWS]->(w)"
		data = run_query(cypher)
		data
	end

	def valid_pronouns_for_Shi
		# Return pronouns with valid_pronouns relation to Shi pattern
		cypher = "MATCH (n:Word{grammar: 'pronoun'})-[r:valid_pronoun]->
										(p:Pattern{name: 'Shi'}) 
							RETURN n"
		data = run_query(cypher)
		data.map{|w| w["simp"]}
	end
	def people
		# Return all nodes with label Person
		cypher = "MATCH (n:Person) 
							RETURN n"
		data = run_query(cypher)
		data
	end

	def words_grouped_by_tones
		cypher = "MATCH (w:Word)-[:HAS_TONE]->(n:ToneCombo) 
							RETURN count(w.simp) AS num, collect(w.simp) AS words, n.tone 
							ORDER BY num"
		graph = @neo.execute_query(cypher)
		graph["data"]
	end

	def grammar_points
		cypher = "MATCH (g)<-[:IS_ABOUT]-(n:GrammarPoint)-[r:CATEGORIZED_AS]->(c) 
							RETURN n.level, n.pattern, n.link, n.eng, n.example, g.name, c.name"
		graph = @neo.execute_query(cypher)
		graph["data"]
	end
	def grammar_points_and_types
		gps = self.grammar_points

		levels_counter = Hash.new(0)
		levels = gps.map{|gp| gp[0]}
		levels.each{|l| levels_counter[l]+=1}

		g_classes_counter = {}
		g_classes = gps.map{|gp| gp[5]}
		g_classes.uniq.each do |g_class|
			g_classes_counter[g_class] = {}
			levels.each {|level| g_classes_counter[g_class][level] = 0}
		end
		gps.each do |gp|
			level = gp[0]
			g_class = gp[5]
			g_classes_counter[g_class][level] += 1
		end
		[gps, levels_counter, g_classes_counter]
	end

	# Writers
	def add_word(word, label=nil)
		node = @neo.create_node(simp: word[:simp], 
													 eng:		word[:eng], 
													 pinyin: Pinyin.t(word[:simp], tonemarks: true))
		@neo.add_label(node, "Word")
		@neo.add_label(node, label) if label
	end

	# Transformers
	def generate_examples(num_examples=1)
		nouns = get_words("noun")
		pronouns = self.valid_pronouns_for_Shi
		examples = []
		num_examples.times do 
			examples << build_shi_pattern(pronouns, nouns)
		end
		[examples, nouns, pronouns]
	end

	private
	def run_query(cypher)
		graph = @neo.execute_query(cypher)
		graph["data"].map{|d| d[0]["data"]}
	end
	def get_words(grammar_category)
		self.words.select{|w| w["grammar"] == grammar_category}.map{|w| w["simp"]}
	end

	def build_shi_pattern(pronouns, nouns)
		pronouns.shuffle.first + "是" + nouns.shuffle.first
	end
end
