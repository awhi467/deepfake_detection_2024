bic_ax_accuracy = [83.817,88.459,92.860,94.052,93.814,93.219];
bic_ax_precision = [85.638,90.151,92.577,93.610,92.830,92.728];
bic_ax_recall = [80.891,86.061,93.103,94.356,94.641,93.593];
bic_rad_accuracy = [83.936,86.257,89.648,89.709,90.602,90.661];
bic_rad_precision = [86.082,87.299,88.769,87.709,89.126,88.955];
bic_rad_recall = [80.488,84.482,90.548,92.099,92.157,92.512];
sk_ax_accuracy = [77.809,78.702,81.795,81.261,82.273,82.332];
sk_ax_precision = [82.332,83.783,83.125,82.928,83.958,83.751];
sk_ax_recall = [70.170,70.522,79.187,78.315,79.382,80.032];
sk_rad_accuracy = [76.143,75.905,80.845,78.347,77.216,77.157];
sk_rad_precision = [79.821,79.032,81.014,78.255,77.076,76.649];
sk_rad_recall = [69.376,70.015,80.049,77.891,76.798,77.475];

n = [1,2,3,4,5,6];
ticks = [1,2,3,4,5,6]
xlabels = {'32','64','128','256','512','1024'};
figure(1)
plot(n,bic_ax_accuracy,n,bic_rad_accuracy,n,sk_ax_accuracy,n,sk_rad_accuracy)
legend(["Bicoherence I_A", "Bicoherence I_R", "Skewness I_A", "Skewness I_R"])
xticks(ticks)
xticklabels(xlabels)
xlabel("FFT size")
ylabel("Accuracy (%)")

figure(2)
plot(n,bic_ax_precision,n,bic_rad_precision,n,sk_ax_precision,n,sk_rad_precision)
%legend(["Bicoherence I_A", "Bicoherence I_R", "Skewness I_A", "Skewness I_R"])
xticks(ticks)
xticklabels(xlabels)
xlabel("FFT size")
ylabel("Precision (%)")


figure(3)
plot(n,bic_ax_recall,n,bic_rad_recall,n,sk_ax_recall,n,sk_rad_recall)
%legend(["Bicoherence I_A", "Bicoherence I_R", "Skewness I_A", "Skewness I_R"])
xticks(ticks)
xticklabels(xlabels)
xlabel("FFT size")
ylabel("Recall (%)")
