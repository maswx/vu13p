#!/usr/bin/python3
# -*- coding: utf-8 -*-
#========================================================================
#        author   : masw
#        creattime: Sun 19 Mar 2023 09:41:08 PM CST
#========================================================================
#---Model: GPT-4
#---
#---用python 产生两个正弦波相加的信号，并设计一个33个系数的FIR滤波器滤除高频信号
#---要使用Python生成两个正弦波相加的信号并设计一个具有33个系数的FIR滤波器以滤除高频信号，您可以使用以下库和代码：
#---
#---安装所需库：
#---bash
#---pip install numpy scipy matplotlib
#---编写Python代码：



import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import firwin, lfilter
def save_txt(signal, filename, scale_factor=(32768/2)):
    # 归一化信号
    norm_signal = signal / np.max(np.abs(signal))

    # 根据给定的规模因子缩放信号
    scaled_signal = np.round(norm_signal * scale_factor)

    # 保存为文本文件
    np.savetxt(filename, scaled_signal, fmt='%d')


# 参数设置
fs = 1000  # 采样频率
duration = 100  # 信号持续时间 (秒)
f1 = 5  # 第一个正弦波的频率 (赫兹)
f2 = 100  # 第二个正弦波的频率 (赫兹)
num_taps = 33  # FIR滤波器的系数个数
cutoff_freq = 30  # 滤波器截止频率 (赫兹)

# 生成时间序列
t = np.linspace(0, duration, int(fs * duration), endpoint=False)

# 生成正弦波信号
sin_wave_1 = np.sin(2 * np.pi * f1 * t)
sin_wave_2 = np.sin(2 * np.pi * f2 * t)
combined_signal = sin_wave_1 + sin_wave_2
# 保存合成信号为文本文件
save_txt(combined_signal, "combined_signal.txt", 6000)

# 设计FIR滤波器
fir_coefficients = firwin(num_taps, cutoff_freq, fs=fs, pass_zero=True, window="hamming")
print(fir_coefficients )
# 保存合成信号为文本文件
save_txt(fir_coefficients, "fir_coefficients.txt")

# 应用滤波器
filtered_signal = lfilter(fir_coefficients, 1.0, combined_signal)

# 绘制原始信号和滤波后的信号
plt.figure()
plt.subplot(2, 1, 1)
plt.plot(t, combined_signal)
plt.title("原始信号")
plt.xlabel("时间 (秒)")
plt.ylabel("幅度")

plt.subplot(2, 1, 2)
plt.plot(t, filtered_signal)
plt.title("滤波后的信号")
plt.xlabel("时间 (秒)")
plt.ylabel("幅度")

plt.tight_layout()
plt.show()

