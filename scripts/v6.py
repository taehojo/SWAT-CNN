import sys
import numpy as np
import pandas as pd
import tensorflow as tf
from keras.models import Sequential
from keras.layers import LSTM, Conv1D, GlobalMaxPooling1D, Dense
from keras.callbacks import EarlyStopping
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split

def check_args():
    if len(sys.argv) != 5:
        sys.stderr.write('Usage: sys.argv[0] start end csv win\n')
        sys.exit(1)

def read_data():
    csv = sys.argv[3]
    df = pd.read_csv(csv, header=None, delim_whitespace=True)
    return df.values

def LSTM_seq(filters, N_in):
    model = Sequential()
    model.add(LSTM(filters, activation='relu', input_shape=(N_in,1)))
    model.add(Dense(5))
    model.add(Dense(1))	
    model.compile(optimizer='adam', loss='mse')
    return model

def CNN_seq(filters, kernel_size, N_in, N_hidden2, N_out):
    model = Sequential()
    model.add(Conv1D(filters, kernel_size, activation="relu", input_shape=(N_in, 1)))
    model.add(GlobalMaxPooling1D())
    model.add(Dense(N_hidden2, activation="relu"))
    model.add(Dense(N_out, activation='softmax', name="dense_e"))
    model.compile(loss='sparse_categorical_crossentropy', optimizer='adam', metrics=['accuracy'])
    return model

def prepare_data(start, win, dataset):
    x = dataset[:,start:start+win]
    Y_obj = dataset[:,0]
    encoder = LabelEncoder()
    encoder.fit(Y_obj)
    Y = encoder.transform(Y_obj)
    X = x.reshape(x.shape[0], x.shape[1], 1)
    X_train1, X_test, Y_train1, Y_test = train_test_split(X, Y, test_size=0.2, random_state=1)
    X_train, X_val, Y_train, Y_val = train_test_split(X_train1, Y_train1, test_size=0.25, random_state=1)
    return (X_train, Y_train, X_test, Y_test, X_val, Y_val)

def main():
    check_args()
    start = int(sys.argv[1])
    end = int(sys.argv[2])
    win = int(sys.argv[4])
    dataset = read_data()

	filters = 20
	kernel_size = 10
	N_in = win
	N_hidden2 = 64
	N_out = 2

	for i in range(start, end):
		model = CNN_seq(filters, kernel_size, N_in, N_hidden2, N_out)
		X_train, Y_train, X_test, Y_test, X_val, Y_val = prepare_data(i, win, dataset)
		early_stopping = EarlyStopping(monitor='val_loss', patience=10)
		history = model.fit(X_train, Y_train, validation_data=(X_val, Y_val), callbacks=[early_stopping], epochs=100, batch_size=32)
    
	
if name == "main":
main()