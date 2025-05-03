import unittest
from src.lib_ml.preprocessor import Preprocessor

class TestPreprocessor(unittest.TestCase):
    def setUp(self):
        self.preprocessor = Preprocessor()
        sample_corpus = [
                            "This is a great restaurant with amazing food",
                            "The service was terrible and the food was bland",
                            "I loved the atmosphere but the staff was rude",
                            "Fantastic place with friendly servers and tasty dishes",
                            "Horrible experience, never coming back",
                            "The menu is creative and the desserts are delicious",
                            "Slow service but the food quality was decent",
                            "Best restaurant in town with excellent customer care",
                            "Disappointing meal and overpriced drinks",
                            "Wonderful ambiance and attentive staff"
                        ]
        self.preprocessor.vectorize(sample_corpus)

    def test_preprocess(self):
        text = "This is a GREAT restaurant!"
        result = self.preprocessor.preprocess(text)
        self.assertIsInstance(result, str)
        self.assertNotIn("GREAT", result)
        self.assertNotIn("!", result)
        self.assertNotIn("is", result)

    def test_vectorize_single(self):
        text = "This is a great restaurant!"
        features = self.preprocessor.vectorize_single(text)
        self.assertEqual(features.shape[1], 50)

if __name__ == "__main__":
    unittest.main()