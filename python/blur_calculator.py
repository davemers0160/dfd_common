import numpy as np
import math
#import cv2 as cv
import bokeh
from bokeh.io import curdoc, output_file
from bokeh.models import ColumnDataSource, Spinner, Range1d, Slider, Legend
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

legend_label = ["fp 1", "fp 2", "CoC Difference"]

source = ColumnDataSource(data=dict(x=[], coc=[], color=[], legend_label=[]))
# source = ColumnDataSource(data=dict(x=[], coc1=[], coc2=[], coc_diff=[]))

# setup the inputs
px_size = Spinner(title="pixel size (um)", low=0.001, high=10.0, step=0.001, value=1.55, width=100)
f_num = Spinner(title="f number", low=0.01, high=100.0, step=0.01, value=2.0, width=100)
f = Spinner(title="focal length (mm)", low=0.1, high=500, step=0.1, value=55, width=100)
do_1 = Slider(title="focus point 1 (m):", start=1, end=20000, step=1, value=100, width=1500, callback_policy="mouseup", callback_throttle=50)
do_2 = Slider(title="focus point 2 (m):", start=1, end=20000, step=1, value=200, width=1500, callback_policy="mouseup")
x_spin = Spinner(title="max x", low=limits[0], high=limits[1], step=1, value=1000, width=100)
y_spin = Spinner(title="max y", low=limits[0], high=limits[1], step=1, value=50, width=100)

coc_plot = figure(plot_height=600, plot_width=1400, title="Quantized Circles of Confusion")
l1=coc_plot.multi_line(xs='x', ys='coc', source=source, line_width=2, color='color', legend='legend_label')
# coc_plot.legend.title = "CoCs"
# coc_plot.line('x', 'coc1', source=source, line_width=2, color='blue', legend=legend_label[0])
# coc_plot.line('x', 'coc2', source=source, line_width=2, color='green', legend=legend_label[1])
# coc_plot.line('x', 'coc_diff', source=source, line_width=2, color='black', line_dash=(2,2), legend=legend_label[2])
coc_plot.xaxis.axis_label = "Range (m)"
coc_plot.yaxis.axis_label = "Pixel Radius"
coc_plot.axis.axis_label_text_font_style = "bold"
coc_plot.x_range = Range1d(start=0, end=x_spin.value)
coc_plot.y_range = Range1d(start=0, end=y_spin.value)
# coc_plot.legend[0].location = (900, 200)
# legend = Legend(items=[(("fp 1", "fp 2", "CoC Difference"), [l1])], location=(0, -60))
# coc_plot.add_layout(legend, 'right')

def update_plot(attr, old, new):

    r, coc1, coc_max1 = coc_calc(f_num.value, f.value, do_1.value * 1000, limits, step)
    r, coc2, coc_max2 = coc_calc(f_num.value, f.value, do_2.value * 1000, limits, step)

    r = r/1000
    px = px_size.value/1000

    q_coc1 = np.ceil(coc1/px)
    q_coc2 = np.ceil(coc2/px)

    q_coc_diff = abs(q_coc1 - q_coc2)

    source.data = dict(x=[r, r, r], coc=[q_coc1, q_coc2, q_coc_diff], color=['blue', 'green', 'black'], legend_label=["fp 1", "fp 2", "CoC Difference"])
    # source.data = dict(x=[r], coc1=[q_coc1], coc2=[q_coc2], coc_diff=[q_coc_diff])

    coc_plot.x_range.end = x_spin.value
    coc_plot.y_range.end = y_spin.value


for w in [px_size, f_num, f, do_1, do_2, x_spin, y_spin]:
    w.on_change('value', update_plot)


update_plot(1, 1, 1)

# layout = column([row([x_spin,y_spin]), blur_plot])
inputs = column(px_size, f_num, f, x_spin, y_spin)
layout = column(row(inputs, coc_plot), do_1, do_2)

show(layout)

doc = curdoc()
doc.title = "Blur Calculator"
doc.add_root(layout)

# output_file("d:/test.html", title='Bokeh Plot', mode='cdn', root_dir=None)
