# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/



$(document).on "page:change", ->
  items = $('.simplex').children()
  pivot = pivot ? 0;
  for i in [0..pivot]
    items.eq(i).show()
  # $('.simplex').delegate '.clickme' , click ->
  $('.clickme').click ->
  	item = $(this)
  	clicked = items.index(item)
  	if clicked == pivot
  	  item.text('Hide steps after this')
  	  collection = item.nextUntil('.clickme')
  	  collection.slideDown(600)
  	  collection.next().fadeIn(1500)
  	  pivot = 1 + items.index(collection.last())
  	else
  	  item.nextAll().slideUp(400)
  	  pivot = items.index(item)
  	  item.text('Reveal next step')
  	  item.nextAll('.clickme').text('Reveal next step')
  
  # $('.simplex').children().first().nextAll().addClass('hidden')
  # $('.simplex').
  # items = $('.simplex')
  # $('.simplex').children().first().nextAll().addClass('hidden')
  # $('.clickme').click ->
  #   el = $(this)
  #   el.append("sibble")
  #   el.nextAll().fadeToggle


# thisElement.next().fadeToggle
# thisElement.next().next().fadeToggle
# thisElement = $('.first');
# thisElement.next().next().addClass('first')
# thisElement.removeClass('first')
# thisElement.next().removeClass('hid')
# thisElement.next().next().removeClass('hid')
# thisElement.next().fadeToggle
# thisElement.next().next().fadeToggle



# $(document).on "page:change", ->
#   $('#test').click ->
#     $('#test-section').fadeToggle()


# `$(function() {
# 	$('h1')
# });`



  

