# TensorFlow and tf.keras
import tensorflow as tf
from tensorflow import keras

# For numpy array manipulation
import numpy as np

loaded_model = keras.models.load_model("keras_model.h5")

(train_images, train_labels), (test_images, test_labels) = keras.datasets.mnist.load_data()
test_images = test_images / 255.0
test_images = test_images.reshape([-1,28,28,1])

test_loss, test_acc = loaded_model.evaluate(test_images, test_labels, batch_size=32)
print("Test accuracy:", test_acc)

image_input = np.expand_dims(test_images[0], axis=0)
print("Prediction for number ", test_labels[0], " is: ", loaded_model.predict_classes(image_input)[0])
