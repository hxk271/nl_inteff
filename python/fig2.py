import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.ticker import FormatStrFormatter

plt.rcParams["font.family"] = "Times New Roman"
plt.rcParams["mathtext.fontset"] = "cm"
fs = 40
plt.rcParams.update({'font.size': fs})

# parameters
beta_0 = 0
beta_1 = 1.5
beta_2 = .5
beta_12_values = [2, 1, .5]

# linear space of x1 and x2
X1, X2 = np.meshgrid(np.linspace(-2, 2, 100),
                     np.linspace(-2, 2, 100))

# limits for color scale
vmin, vmax = -.5, .5


# a figure with 2 subplots side by side
fig = plt.figure(figsize=(64, 48))
gs = fig.add_gridspec(3, 2, width_ratios=[1, 6],
                      wspace=-.7,    # space between columns
                      hspace=0.2)    # space between rows

for i, beta_12 in enumerate(beta_12_values):
    
    # XB and P(Y=1)
    XB = beta_0 + beta_1 * X1 + beta_2 * X2 + beta_12 * X1 * X2

    # logistic cdf
    p = 1 / (1 + np.exp(-XB))
    
    # logistic pdf. exp(-XB)/(1 + exp(-XB))^2 is the derivative of the logistic cdf (p above)
    phi = p * (1 - p)

    # interaction effect as cross-partial derivative
    interaction_effect = phi * ((1-2*p) * (beta_1+beta_12*X2) * (beta_2+beta_12*X1) + beta_12)
    pos = [inteff>0 for inteff in interaction_effect.flat].count(1) / (100*100)
    neg = [inteff<0 for inteff in interaction_effect.flat].count(1) / (100*100)

    
    
    # Heatmap
    ax1 = fig.add_subplot(gs[i, 0])
    ax1.set_title("Heatmap ($b_{12}="+str(beta_12)+"$), $"+str(round(pos,2))+"\%_+$, $"+str(round(neg,2))+"\%_-$",
                   fontsize=fs)
    sns.heatmap(interaction_effect, xticklabels=5, yticklabels=5, cmap='coolwarm',
                center=0, vmin=vmin, vmax=vmax, cbar=False, ax=ax1)
    #ax1.set_title(f"$\\beta_1$ = {beta_1}")
    ax1.set_xlabel('$X_1$')
    ax1.set_xticks(np.linspace(0, 99, 5))
    ax1.set_xticklabels(np.linspace(-2, 2, 5).astype(int))
    ax1.invert_yaxis()  # otherwise y-axis is inverted
    ax1.set_ylabel('$X_2$')
    ax1.set_yticks(np.linspace(0, 99, 5))
    ax1.set_yticklabels(np.linspace(-2, 2, 5).astype(int))

    # 3D Surface plot
    ax2 = fig.add_subplot(gs[i, 1], projection='3d')
    ax2.set_title("3D Surface Plot ($b_{12}="+str(beta_12)+"$)", fontsize=fs)
    ax2.plot_surface(X1, X2, interaction_effect, cmap='coolwarm', edgecolor='none', 
                     vmin=vmin, vmax=vmax)
    #ax2.set_title(f"$\\beta_1$ = {beta_1}")
    ax2.set_xlabel('$X_1$', labelpad=30)
    ax2.set_xticks(np.linspace(-2, 2, 5))
    ax1.set_xticklabels(np.linspace(-2, 2, 5).astype(int))
    ax2.set_ylabel('$X_2$', labelpad=30)
    ax2.set_yticks(np.linspace(-2, 2, 5))
    #ax2.set_yticks(np.linspace(ymin, ymax, 4))
    ax2.zaxis.set_major_formatter(FormatStrFormatter('%.1f'))
    ax2.set_zlabel('Interaction Effect', labelpad=45)
    ax2.zaxis.set_tick_params(pad=20)
    #ax2.set_zticklabels(np.linspace(-.2, .2, 5))
    ax2.view_init(elev=25, azim=-115)

plt.subplots_adjust(left=0.006, right=0.94, top=0.95, bottom=0.05)
#plt.tight_layout()
plt.savefig('fig2.png', dpi=50, bbox_inches='tight')
plt.show()
