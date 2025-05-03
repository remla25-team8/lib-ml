import re
import nltk
from nltk.corpus import stopwords
from nltk.stem.porter import PorterStemmer
from sklearn.feature_extraction.text import CountVectorizer
import pickle
import os

nltk.download('punkt')
nltk.download('stopwords')

class Preprocessor:
    def __init__(self, vectorizer_path=None, max_features=1420):
        self.ps = PorterStemmer()
        self.all_stopwords = set(stopwords.words('english'))
        self.all_stopwords.remove('not')
        if vectorizer_path and os.path.exists(vectorizer_path):
            self.vectorizer = pickle.load(open(vectorizer_path, "rb"))
        else:
            self.vectorizer = CountVectorizer(max_features=max_features)

    def preprocess(self, text):
        text = re.sub('[^a-zA-Z]', ' ', text)
        text = text.lower()
        text = text.split()
        text = [self.ps.stem(word) for word in text if word not in self.all_stopwords]
        return ' '.join(text)

    def preprocess_batch(self, texts):
        return [self.preprocess(text) for text in texts]

    def vectorize(self, texts):
        return self.vectorizer.fit_transform(texts).toarray()

    def vectorize_single(self, text):
        if not hasattr(self.vectorizer, 'vocabulary_'):
            raise ValueError("CountVectorizer not fitted. Call vectorize() or load_vectorizer() first.")
        processed = self.preprocess(text)
        return self.vectorizer.transform([processed]).toarray()

    def save_vectorizer(self, path):
        with open(path, 'wb') as f:
            pickle.dump(self.vectorizer, f)

    def load_vectorizer(self, path):
        self.vectorizer = pickle.load(open(path, "rb"))