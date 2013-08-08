require 'pry'

module BayesianClassifier
  class Trainer
    attr_accessor :trained

    def initialize(categories)
      @trained = {}
      categories.each { |category| @trained[category] = {}}

      @categories = Hash.new(0)
    end

    def train(category, attributes)
      @categories[category] += 1

      attributes.each do |attribute, value|
        @trained[category][attribute] ||= Hash.new(0)
        @trained[category][attribute][value] += 1
      end
    end

    # P(V|S)
    def feature_prob(category, attributes)
      attributes.inject(1) do |product, (feature, value)|
        lprob = (@trained[category][feature][value] / @categories[category].to_f)
        product * lprob
      end
    end

    # Prob(S)
    def category_prob(category)
      @categories[category].to_f / @categories.values.reduce(:+)
    end

    # Prob(S|V)
    def attributes_probability(category, attributes)
      feature_prob(category, attributes) * category_prob(category)
    end

    def find_category(attributes)
      lmax = 0
      cat = :unknown

      @categories.keys.each do |category|
        calc = attributes_probability(category, attributes)

        if calc > lmax
          lmax = calc
          cat = category
        end
      end

      (@categories.keys - [cat]).each do |category|
        calc = attributes_probability(category, attributes)

        if calc * 3 > lmax
          cat = :unknown
        end
      end


      [cat, lmax]
    end
  end
end

include BayesianClassifier

trainer = Trainer.new([0, 1])

data = File.read("all_data.in")

desc = [
  :age,
  :sex,
  :cp,
  :trestbps,
  :chol,
  :fbs,
  :restecg,
  :thalach,
  :exang,
  :oldpeak,
  :slope,
  :ca,
  :thal
]

instances = []


data.each_line do |line|
  attributes = line.split(",")

  instance = {}

  for i in (0...attributes.size-1)
    instance[desc[i]] = attributes[i].to_i
  end

  category = attributes.last.strip.to_i >= 1 ? 1 : 0

  instances << [category, instance]
end

rels = []

# 1000.times do |i|
  instances.shuffle!

  # instances[0..-5].each do |(category, instance)|
  instances.each do |(category, instance)|
    trainer.train(category, instance)
  end

  total = 0
  right = 0
  unknown = 0
  wrong = 0
  false_positives = 0
  false_negatives = 0

  # instances[-5..-1].each do |(category, instance)|
  instances.each do |(category, instance)|
    total += 1
    predicted = trainer.find_category(instance)[0]

    if predicted == category
      right += 1
    elsif predicted == :unknown
      unknown += 1
    else
      if category == 0
        false_negatives += 1
      else
        false_positives += 1
      end

      wrong += 1
    end
  end

  # puts i if i % 100 == 0

  rels << (right / total.to_f)
# end

# puts rels.reduce(:+) / rels.size

puts "Total: #{total}"
puts "Reliable: #{right}, #{right.to_f/total}"
puts "Unknown/not reliable: #{unknown}, #{unknown.to_f/total}"
puts "Wrong: #{wrong}, #{wrong.to_f/total}"
puts "\tFalse positives: #{false_positives}"
puts "\tFalse negatives: #{false_negatives}\n\n"
p right.to_f/total
