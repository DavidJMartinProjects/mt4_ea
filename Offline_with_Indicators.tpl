<chart>
id=132383515007667691
symbol=GBPUSD
period=62
leftpos=3843
offline=1
digits=5
scale=4
graph=1
fore=0
grid=0
volume=0
scroll=1
shift=1
ohlc=1
one_click=1
one_click_btn=1
askline=0
days=0
descriptions=0
shift_size=17
fixed_pos=0
window_left=958
window_top=0
window_right=1916
window_bottom=816
window_type=1
background_color=16777215
foreground_color=0
barup_color=0
bardown_color=0
bullcandle_color=16777215
bearcandle_color=0
chartline_color=0
volumes_color=32768
grid_color=12632256
askline_color=17919
stops_color=17919

<window>
height=100
fixed_height=0
<indicator>
name=main
<object>
type=23
object_name=Spread
period_flags=0
create_time=1372144057
description=Spread: 0 points.
color=255
font=Arial
fontsize=14
angle=0
anchor_pos=0
background=0
filling=0
selectable=1
hidden=0
zorder=0
corner=0
x_distance=10
y_distance=130
</object>
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=Spread
flags=339
window_num=0
<inputs>
font_color=255
font_size=14
font_face=Arial
corner=0
spread_distance_x=10
spread_distance_y=130
normalize=0
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=0
style_0=0
weight_0=0
period_flags=0
show_data=1
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=half-trend nrp
flags=339
window_num=0
<inputs>
Amplitude=2
ColorUp=3329330
ColorDown=3937500
LinesWidth=2
HistogramWidth=2
ShowBars=false
ShowArrows=true
alertsOn=false
alertsOnCurrent=false
alertsMessage=true
alertsSound=false
alertsEmail=false
alertsPush=false
</inputs>
</expert>
shift_0=0
draw_0=12
color_0=3329330
style_0=0
weight_0=2
shift_1=0
draw_1=12
color_1=3937500
style_1=0
weight_1=2
shift_2=0
draw_2=0
color_2=3329330
style_2=0
weight_2=2
shift_3=0
draw_3=0
color_3=3937500
style_3=0
weight_3=2
shift_4=0
draw_4=0
color_4=3937500
style_4=0
weight_4=2
shift_5=0
draw_5=3
color_5=3329330
style_5=0
weight_5=0
arrow_5=233
shift_6=0
draw_6=3
color_6=3937500
style_6=0
weight_6=0
arrow_6=234
period_flags=0
show_data=1
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=hull_moving_average_2.0_amp_sr_lines_arrows
flags=339
window_num=0
<inputs>
TimeFrame=Current time frame
HMAPeriod=144
HMAPrice=0
HMASpeed=1.0
LinesVisible=false
LinesNumber=5
ColorUp=16711680
ColorDown=255
UniqueID=HullLines1
alertsOn=false
alertsOnCurrent=true
alertsMessage=false
alertsSound=false
alertsEmail=false
ShowArrows=true
arrowSize=2
uparrowCode=233
dnarrowCode=234
ArrowsOnFirstBar=true
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=16711680
style_0=0
weight_0=2
shift_1=0
draw_1=0
color_1=255
style_1=0
weight_1=2
shift_2=0
draw_2=0
color_2=255
style_2=0
weight_2=2
shift_3=0
draw_3=3
color_3=16748574
style_3=0
weight_3=2
arrow_3=233
shift_4=0
draw_4=3
color_4=16711935
style_4=0
weight_4=2
arrow_4=234
period_flags=0
show_data=1
</indicator>
<indicator>
name=Custom Indicator
<expert>
name=vh
flags=339
window_num=0
</expert>
shift_0=0
draw_0=3
color_0=255
style_0=1
weight_0=0
arrow_0=159
shift_1=0
draw_1=3
color_1=16711680
style_1=1
weight_1=0
arrow_1=159
shift_2=0
draw_2=12
color_2=0
style_2=0
weight_2=0
shift_3=0
draw_3=12
color_3=0
style_3=0
weight_3=0
shift_4=0
draw_4=12
color_4=0
style_4=0
weight_4=0
shift_5=0
draw_5=12
color_5=0
style_5=0
weight_5=0
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=50
fixed_height=0
<indicator>
name=Custom Indicator
<expert>
name=ScalpCycle
flags=339
window_num=1
<inputs>
AlertOn=false
EMA_period=15
Stochastic_period=19
</inputs>
</expert>
shift_0=0
draw_0=2
color_0=2631720
style_0=0
weight_0=1
shift_1=0
draw_1=3
color_1=13158600
style_1=0
weight_1=1
arrow_1=217
shift_2=0
draw_2=3
color_2=230
style_2=0
weight_2=1
arrow_2=218
min=0.00000000
max=100.00000000
levels_color=12632256
levels_style=2
levels_weight=1
level_0=10.00000000
level_1=90.00000000
period_flags=0
show_data=1
</indicator>
</window>
</chart>

