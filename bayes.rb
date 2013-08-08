class Bayes
  def initialize
    @frequency  = {}
    @categories = Hash.new 0
  end

  # Prob(Category|Features) = Prob(Category) Prob(Features|Category)
  def probability(features, category)
    features_probability(features, category) * category_probability(category)
  end

  # Prob(Features|Category)
  def features_probability(features, category)
    features.inject(1) { |p, feature| p * weighted_feature_probability(feature, category) }
  end

  # Prob(Category)
  def category_probability(category)
    @categories[category].to_f / @categories.values.reduce(:+)
  end

  # Prob(Feature|Category)
  def feature_probability(feature, category, start = 0.0)
    return start unless @frequency[category][feature] > 0

    @frequency[category][feature] / @categories[category].to_f
  end

  # Prob(Feature|Category) accounting for low frequency features in the
  # training set.
  def weighted_feature_probability(feature, category, weight = 1.0, start = 0.5)
    basic = feature_probability(feature, category)
    total = feature_count(feature)

    ((weight * start) + (total * basic)) / (weight + total)
  end

  # Prepare for calculating Prob(Feature|Category), from which
  # Prob(Features|Category) can be derived.
  def train(features, category)
    @frequency[category] = Hash.new(0) unless @frequency[category]

    features.each do |feature|
      @frequency[category][feature] += 1
    end

    @categories[category] += 1
  end

  def sample_train
    train('Nobody owns the water.'.split,'good')
    train('the quick rabbit jumps fences'.split,'good')
    train('buy pharmaceuticals now'.split,'bad')
    train('make quick money at the online casino'.split,'bad')
    train('the quick brown fox jumps'.split,'good')
  end

  private
  def feature_count(feature)
    @frequency.values.inject(0) { |sum, features| sum + features[feature] }
  end
end

bayes = Bayes.new

bayes.sample_train

p bayes.weighted_feature_probability("money", "bad")
