# TensorFlow and tf.keras
import tensorflow as tf
from tensorflow import keras

mnist_dataset = keras.datasets.mnist
(train_images, train_labels), (test_images, test_labels) = mnist_dataset.load_data()

train_images = train_images / 255.0
test_images = test_images / 255.0

train_images = train_images.reshape([-1,28,28,1])
test_images = test_images.reshape([-1,28,28,1])

model = keras.Sequential([
    keras.layers.Conv2D(32, (5, 5), padding="same", activation=tf.nn.relu, input_shape=(28, 28, 1),
                        use_bias=True, bias_initializer=keras.initializers.Constant(value=0.1),
                        kernel_initializer=keras.initializers.TruncatedNormal(mean=0.0, stddev=0.1, seed=None)),
    keras.layers.MaxPooling2D(pool_size=(2,2), strides=(2,2), padding="same"),
    keras.layers.Conv2D(64, (5, 5), padding="same", activation=tf.nn.relu, input_shape=(14, 14, 32),
                        use_bias=True, bias_initializer=keras.initializers.Constant(value=0.1),
                        kernel_initializer=keras.initializers.TruncatedNormal(mean=0.0, stddev=0.1, seed=None)),
    keras.layers.MaxPooling2D(pool_size=(2,2), strides=(2,2), padding="same"),
    keras.layers.Flatten(input_shape=(7, 7, 64)),
    keras.layers.Dense(1024, activation=tf.nn.relu),
    keras.layers.Dropout(0.5),
    keras.layers.Dense(10, activation=tf.nn.softmax)
])

model.compile(optimizer=keras.optimizers.Adam(lr=1e-4), 
              loss="sparse_categorical_crossentropy",
              metrics=["accuracy"])

model.fit(train_images, train_labels, batch_size=32, epochs=4)
model.save("keras_model.h5")

test_loss, test_acc = model.evaluate(test_images, test_labels, batch_size=32)
print("Test accuracy:", test_acc)
