import numpy as np
import math
import cv2 as cv
import bokeh
from bokeh.io import curdoc
from bokeh.models import ColumnDataSource
from bokeh.plotting import figure, show
from bokeh.layouts import column, row, Spacer

from coc_calc import coc_calc


f_num = 3.7
f = 10
d_o = 2
limits = [0, 1000000]
step = 100
px_size = 0.00155

r, coc, coc_max = coc_calc(f_num, f, d_o*1000, limits, step)

q_coc = np.ceil(coc/px_size)
q_coc_max = math.ceil(coc_max/px_size)

test = 1
