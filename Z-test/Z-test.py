import scipy.stats as stats
import numpy as np
from scipy.optimize import curve_fit
from scipy.stats import sem
import matplotlib.pyplot as plt

treats = [['gNT_ABA','gNT_DMSO'],['gT_ABA','gT_DMSO']]

def one_phase_decay(t, K):
    return np.exp(-K * t)

colors = ['red','blue']
KK = [];sterr = []
for t in range(2):
    KK = [];VV = []
    for c in range(2):
        f = open(treats[t][c]+'_new.txt')
        a = f.readlines();f.close()
        del a[0]
        time = [];values = []
        for i in [0,3,4,5,6]:
            a[i] = a[i].split('\t')
            for j in range(3):
                time.append(float(a[i][0]))
                values.append(float(a[i][j+1]))
                plt.scatter(float(a[i][0]), (float(a[i][1])+float(a[i][2])+float(a[i][3]))/3, color=colors[c])

        time = np.array(time)
        values = np.array(values)/np.mean(values[0:3])

        popt, pcov = curve_fit(one_phase_decay, time, values)
        K_fit = popt[0]
        K_cov = pcov[0][0]
        print(treats[t][c],K_fit,K_cov)
        
        x_fit = np.linspace(0, 50, 100)
        y_fit = one_phase_decay(x_fit,K_fit)
        plt.plot(x_fit, y_fit, label=treats[t][c], color=colors[c])

        KK.append(K_fit);VV.append(K_cov)
    plt.show()
    z = (KK[1] - KK[0]) / np.sqrt(VV[1] + VV[0])
    p_value = (1 - stats.norm.cdf(z))
    print(treats[t],z,p_value)
