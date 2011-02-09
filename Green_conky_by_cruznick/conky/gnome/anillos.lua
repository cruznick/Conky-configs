--[[
Conky Widgets by londonali1010 (2009)
 
This script is meant to be a "shell" to hold a suite of widgets for use in Conky.
 
To configure:
+ Copy the widget's code block (will be framed by --(( WIDGET NAME )) and --(( END WIDGET NAME )), with "[" instead of "(") somewhere between "require 'cairo'" and "function conky_widgets()", ensuring not to paste into another widget's code block
+ To call the widget, add the following just before the last "end" of the entire script:
	cr = cairo_create(cs)
	NAME_OF_FUNCTION(cr, OPTIONS)
	cairo_destroy(cr)
+ Replace OPTIONS with the options for your widget (should be specified in the widget's code block) 
 
Call this script in Conky using the following before TEXT (assuming you save this script to ~/scripts/conky_widgets.lua):
	lua_load ~/scripts/conky_widgets.lua
	lua_draw_hook_pre widgets
 
Changelog:
+ v1.0 -- Original release (17.10.2009)
]]
 
require 'cairo'
 --[[ RING WIDGET ]]
--[[ Options (name, arg, max, bg_colour, bg_alpha, xc, yc, radius, thickness, start_angle, end_angle):
	"name" is the type of stat to display; you can choose from 'cpu', 'memperc', 'fs_used_perc', 'battery_used_perc'.
	"arg" is the argument to the stat type, e.g. if in Conky you would write ${cpu cpu0}, 'cpu0' would be the argument. If you would not use an argument in the Conky variable, use ''.
	"max" is the maximum value of the ring. If the Conky variable outputs a percentage, use 100.
	"bg_colour" is the colour of the base ring.
	"bg_alpha" is the alpha value of the base ring.
	"fg_colour" is the colour of the indicator part of the ring.
	"fg_alpha" is the alpha value of the indicator part of the ring.
	"x" and "y" are the x and y coordinates of the centre of the ring, relative to the top left corner of the Conky window.
	"radius" is the radius of the ring.
	"thickness" is the thickness of the ring, centred around the radius.
	"start_angle" is the starting angle of the ring, in degrees, clockwise from top. Value can be either positive or negative.
	"end_angle" is the ending angle of the ring, in degrees, clockwise from top. Value can be either positive or negative, but must be larger (e.g. more clockwise) than start_angle. ]]
 
function ring(cr, name, arg, max, bgc, bga, fgc, fga, xc, yc, r, t, sa, ea)
	local function rgb_to_r_g_b(colour,alpha)
		return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
	end
 
	local function draw_ring(pct)
		local angle_0=sa*(2*math.pi/360)-math.pi/2
		local angle_f=ea*(2*math.pi/360)-math.pi/2
		local pct_arc=pct*(angle_f-angle_0)
 
		-- Draw background ring
 
		cairo_arc(cr,xc,yc,r,angle_0,angle_f)
		cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
		cairo_set_line_width(cr,t)
		cairo_stroke(cr)
 
		-- Draw indicator ring
 
		cairo_arc(cr,xc,yc,r,angle_0,angle_0+pct_arc)
		cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
		cairo_stroke(cr)
	end
 
	local function setup_ring()
		local str = ''
		local value = 0
 
		str = string.format('${%s %s}', name, arg)
		str = conky_parse(str)
 
		value = tonumber(str)
		if value == nil then value = 0 end
		pct = value/max
 
		draw_ring(pct)
	end	
 
	local updates=conky_parse('${updates}')
	update_num=tonumber(updates)
 
	if update_num>5 then setup_ring() end
end
 
--[[ END RING WIDGET ]]
--[[ CLOCK HANDS WIDGET ]]
--[[ Options (xc, yc, colour, alpha, show_secs, size):
	"xc" and "yc" are the x and y coordinates of the centre of the clock hands, in pixels, relative to the top left corner of the Conky window
	"colour" is the colour of the clock hands, in OxFFFFFF formate
	"alpha" is the alpha of the hands, between 0 and 1
	"show_secs" is a boolean; set to TRUE to show the seconds hand, otherwise set to FALSE
	"size" is the total size of the widget (e.g. twice the length of the minutes hand), in pixels ]]

function clock_hands(cr, xc, yc, colour, alpha, show_secs, size)
	local function rgb_to_r_g_b(colour,alpha)
		return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
	end
	
	local secs,mins,hours,secs_arc,mins_arc,hours_arc
	local xh,yh,xm,ym,xs,ys

	secs=os.date("%S")
	mins=os.date("%M")
	hours=os.date("%I")

	secs_arc=(2*math.pi/60)*secs
	mins_arc=(2*math.pi/60)*mins+secs_arc/60
	hours_arc=(2*math.pi/12)*hours+mins_arc/12

	xh=xc+0.4*size*math.sin(hours_arc)
	yh=yc-0.4*size*math.cos(hours_arc)
	cairo_move_to(cr,xc,yc)
	cairo_line_to(cr,xh,yh)

	cairo_set_line_cap(cr,CAIRO_LINE_CAP_ROUND)
	cairo_set_line_width(cr,5)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(colour,alpha))
	cairo_stroke(cr)

	xm=xc+0.5*size*math.sin(mins_arc)
	ym=yc-0.5*size*math.cos(mins_arc)
	cairo_move_to(cr,xc,yc)
	cairo_line_to(cr,xm,ym)

	cairo_set_line_width(cr,3)
	cairo_stroke(cr)

	if show_secs then
		xs=xc+0.5*size*math.sin(secs_arc)
		ys=yc-0.5*size*math.cos(secs_arc)
		cairo_move_to(cr,xc,yc)
		cairo_line_to(cr,xs,ys)

		cairo_set_line_width(cr,1)
		cairo_stroke(cr)
	end
end

--[[ END CLOCK HANDS WIDGET ]]
function conky_widgets()
	if conky_window == nil then return end
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
cr = cairo_create(cs)
clock_hands(cr, 350, 55, 0xFF4D00, 0.5, true, 70)
	cairo_destroy(cr)
end
