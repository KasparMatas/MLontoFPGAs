# Very simple model which saves its weights as well. Done without Keras and Estimator API. Just using the SavedModel API.
# Wanted to do it as vanilla TensorFlow as possible but it's just too pointlessly hard.
import tensorflow as tf
import numpy as np
from tensorflow.examples.tutorials.mnist import input_data

import os
dir = os.path.dirname(os.path.realpath(__file__))

# Load the MNIST data set
mnist_data = input_data.read_data_sets("MNIST_data/", one_hot=True) # Deprecated

# The basic MLP graph
x = tf.placeholder(tf.float32, shape=[None, 784])
W = tf.Variable(tf.zeros([784, 10]))
b = tf.Variable(tf.zeros([10]))
y = tf.nn.softmax(tf.add(tf.matmul(x, W),b))

# The placeholder for the correct result
real_y = tf.placeholder(tf.float32, [None, 10])

# Loss function
cross_entropy = tf.reduce_mean(-tf.reduce_sum(real_y * tf.log(y), axis=[1]))
# Optimization
optimizer = tf.train.GradientDescentOptimizer(0.5)
train_step = optimizer.minimize(cross_entropy)

# Accuracy
correct_prediction = tf.equal(tf.argmax(y, 1), tf.argmax(real_y, 1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))

# Initialization
init = tf.global_variables_initializer()

# Starting Tensorflow session
with tf.Session() as session:

    # To generate data for tensorboard
    #train_writer = tf.summary.FileWriter(dir + '/saver_graph', session.graph)
    #train_writer.close()
    
    # Training using MNIST dataset
    epochs = 1000
    session.run(init)
    for _ in range(epochs):
        batch_x, batch_y = mnist_data.train.next_batch(100)
        session.run(train_step, feed_dict={x: batch_x, real_y: batch_y})
    network_accuracy = session.run(accuracy, feed_dict={x: mnist_data.test.images, real_y: mnist_data.test.labels})
    print('The accuracy over the MNIST data is {:.2f}%'.format(network_accuracy * 100))

    # Easy approach:
    # Save - same as using builder.add_meta_graph_and_variables but with loads of defaults
    tf.saved_model.simple_save(session, dir + '/saver_data', inputs={"x": x, "y": real_y},outputs={"z": accuracy})

    # Slightly more defined approach. Needs more research and effort but should produce the same as above:
    # https://github.com/tensorflow/serving/blob/master/tensorflow_serving/example/mnist_saved_model.py
    # With the example above you can see that even more indepth costumisation is possible so more tricks possible to exploit while loading.
    
    
