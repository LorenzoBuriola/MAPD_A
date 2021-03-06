import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import firwin

#Compute the coefficient of the FIR filter
N = 5
fs = 11025
fcut = 0.1*fs/2
coeff = firwin(N, fcut, pass_zero='lowpass', fs = fs)
print("FIR filter coefficients: ", coeff)

#Read the input file and put data in an array
ifile = open("input_vectors.txt", 'r')
lines = ifile.readlines()
x = np.zeros(len(lines))
for i in range(len(lines)):
    x[i] = int(lines[i])

#Filter
index = int((N-1)/2)
y = np.zeros_like(x)
for i in range(x.size-N+1):
    y[i+index] = np.dot(x[i:N+i], coeff[::-1])

#Plot the signals
plt.stem(x, linefmt='b-', markerfmt='bo', basefmt= 'k--')
plt.stem(y, linefmt='r-', markerfmt='ro', basefmt='k--')
plt.show()


