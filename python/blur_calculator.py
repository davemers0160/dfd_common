import numpy as np
import math
import cv2 as cv
import bokeh
from bokeh.io import curdoc
from bokeh.models import ColumnDataSource, Spinner, Range1d, Slider
from bokeh.plotting import figure, show
from bokeh.layouts import column, row, Spacer

from coc_calc import coc_calc


# f_num = 3.7
# f = 10
# d_o1 = 2
# d_o2 = 5
limits = [0, 10000000]
step = 1000
# px_size = 0.00155

# r, coc, coc_max = coc_calc(f_num, f, d_o*1000, limits, step)

# q_coc = np.ceil(coc/px_size)
# q_coc_max = math.ceil(coc_max/px_size)

source = ColumnDataSource(data=dict(x=[], coc=[], color=[], line_dash=["solid", "solid","dashed"]))

# setup the inputs
px_size = Spinner(title="pixel size", low=0.000001, high=1.0, step=0.000001, value=0.000155, width=100)
f_num = Spinner(title="f number", low=0.01, high=100.0, step=0.01, value=2.0, width=100)
f = Spinner(title="focal length", low=0.1, high=500, step=0.1, value=55, width=100)
do_1 = Slider(title="do_1", start=1, end=10000, step=1, value=100, width=100)
do_2 = Slider(title="do_1", start=1, end=10000, step=1, value=200, width=100)
x_spin = Spinner(low=limits[0], high=limits[1], step=1, value=2000, width=100)
y_spin = Spinner(low=limits[0], high=limits[1], step=1, value=10, width=100)

coc_plot = figure(plot_height=350, plot_width=750, title="Circle of Confusion")
coc_plot.multi_line(xs='x', ys='coc', source=source, line_width=2, color='color', line_dash='line_dash')
coc_plot.xaxis.axis_label = "Range (m)"
coc_plot.yaxis.axis_label = "Pixel"
coc_plot.axis.axis_label_text_font_style = "bold"


def update_plot(attr, old, new):

    r, coc1, coc_max1 = coc_calc(f_num.value, f.value, do_1.value * 1000, limits, step)
    r, coc2, coc_max2 = coc_calc(f_num.value, f.value, do_2.value * 1000, limits, step)

    r = r/1000

    q_coc1 = np.ceil(coc1/px_size.value)
    q_coc2 = np.ceil(coc2/px_size.value)

    q_coc_diff = abs(q_coc1 - q_coc2)

    source.data = dict(x=[r, r, r], coc=[q_coc1, q_coc2, q_coc_diff], color=['blue', 'green', 'black'])

    coc_plot.x_range = Range1d(start=0, end=1000)
    coc_plot.y_range = Range1d(start=0, end=100)


for w in [px_size, f_num, f, do_1, do_2, x_spin, y_spin]:
    w.on_change('value', update_plot)


update_plot(1,1,1)

# layout = column([row([x_spin,y_spin]), blur_plot])
inputs = column(px_size, f_num, f, do_1, do_2, x_spin, y_spin)
layout = row(inputs, coc_plot)

show(layout)

doc = curdoc()
doc.title = "Blur Calculator"
doc.add_root(layout)


