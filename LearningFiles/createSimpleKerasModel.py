# TensorFlow and tf.keras
import tensorflow as tf
from tensorflow import keras

import numpy as np
	
mnist_dataset = keras.datasets.mnist
(train_images, train_labels), (test_images, test_labels) = mnist_dataset.load_data()

train_images = train_images / 255.0
test_images = test_images / 255.0

train_images = train_images.reshape(-1,784)
test_images = test_images.reshape(-1,784)

model = keras.Sequential([
    keras.layers.Dense(100, activation=None, input_shape = (784,), use_bias=False),
    keras.layers.Dense(10, activation=None, input_shape = (100,), use_bias=False),
	keras.layers.Dense(10, activation=tf.nn.softmax, input_shape = (10,), use_bias=False)
])

model.compile(optimizer=keras.optimizers.Adam(lr=1e-4), 
              loss="sparse_categorical_crossentropy",
              metrics=["accuracy"])

model.fit(train_images, train_labels, batch_size=32, epochs=4)
model.save("simple_keras_model.h5")

#test_loss, test_acc = model.evaluate(test_images, test_labels, batch_size=32)
#print("Test accuracy:", test_acc)

np.savetxt("test_data", test_images[0:1000])