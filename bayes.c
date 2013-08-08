#include<stdio.h>
#include<stdlib.h>

typedef struct CorpusInstance {
  size_t n_attributes;
  int *attributes;

  int category;
} CorpusInstance;

void
corpus_instance_initialize(CorpusInstance *ci, size_t n_attributes)
{
  ci->attributes = (int*) calloc(n_attributes, sizeof(int));
  ci->n_attributes = n_attributes;
}

typedef struct Feature {
  int *values;
  size_t n_values;
} Feature;

typedef struct TrainedSet {
  size_t n_features;
  Feature *features;

  size_t n_categories;
  int *categories;
} TrainedSet;

void
trained_set_initialize(TrainedSet *ts, size_t n_features, size_t n_categories)
{
  ts->features = (Feature*) malloc(n_features * sizeof(Feature));
  ts->n_features = n_features;

  for(size_t i = 0; i < n_features; i++)
  {
    ts->features[i].values = (int*) calloc(n_features, sizeof(int));
  }

  ts->categories = (int*) calloc(n_categories, sizeof(int));
  ts->n_categories = n_categories;
}

void
trained_set_train(TrainedSet *ts, CorpusInstance *ci)
{
  for(size_t i = 0; i < ci->n_attributes; i++)
  {
    ts->features[i].values[ci->attributes[i]]++;
  }

  ts->categories[ci->category]++;
}

// P(C)
double
trained_set_category_prob(TrainedSet *ts, int category)
{
  double category_sum = 0;

  for(size_t i = 0; i < ts->n_categories; i++)
  {
    category_sum += ts->categories[i];
  }

  return ts->categories[category] / category_sum;
}

// P(V|S)
double
trained_set_attribute_prob(TrainedSet *ts, size_t feature, size_t value, size_t category)
{
  return ts->features[feature].values[value] / ts->categories[category];
}

int main()
{
  CorpusInstance ci;
  corpus_instance_initialize(&ci, 3);
  ci.attributes[0] = 1;
  ci.attributes[1] = 2;
  ci.attributes[2] = 0;
  ci.category = 0;

  CorpusInstance ci2;
  corpus_instance_initialize(&ci2, 3);
  ci2.attributes[0] = 2;
  ci2.attributes[1] = 2;
  ci2.attributes[2] = 1;
  ci2.category = 1;

  TrainedSet ts;
  trained_set_initialize(&ts, 3, 2);
  trained_set_train(&ts, &ci);
  trained_set_train(&ts, &ci2);

  printf("Prob(S): %.2f\n", trained_set_category_prob(&ts, 1));

  return 0;
}
