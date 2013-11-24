
set_new_howlong = () ->
  year = (Session.get('year')) or 2013
  monthjs = (Session.get('monthjs')) or 10
  day = (Session.get('day')) or 27
  hour = (Session.get('hour')) or 19
  minute = (Session.get('minute')) or 0
  Session.set('howlong', window.countdown(new Date(), new Date(year, monthjs, day, hour, minute) ).toString())

got_json = (e, d) -> 
  console.log(d.content)
  dd = EJSON.parse(d.content)
  console.log(dd)
  if dd.feed.entry[0].gsx$cta.$t then Session.set('cta', dd.feed.entry[0].gsx$cta.$t)
  if dd.feed.entry[0].gsx$readable_date.$t then Session.set('readable_date', dd.feed.entry[0].gsx$readable_date.$t)
  if dd.feed.entry[0].gsx$headline.$t then Session.set('headline', dd.feed.entry[0].gsx$headline.$t)
  if dd.feed.entry[0].gsx$year.$t then Session.set('year', parseInt(dd.feed.entry[0].gsx$year.$t))
  if dd.feed.entry[0].gsx$monthjs.$t then Session.set('monthjs', parseInt(dd.feed.entry[0].gsx$monthjs.$t))
  if dd.feed.entry[0].gsx$day.$t then Session.set('day', parseInt(dd.feed.entry[0].gsx$day.$t))   
  if dd.feed.entry[0].gsx$hour.$t then Session.set('hour', parseInt(dd.feed.entry[0].gsx$hour.$t))
  if dd.feed.entry[0].gsx$min.$t then Session.set('min', parseInt(dd.feed.entry[0].gsx$min.$t)) 

fetchGoogleSpreadsheetAndSetData = ->
  HTTP.get('https://spreadsheets.google.com/feeds/list/0Avfklpg3IDw2dDZybGdmQlNsYlY5M0QyODRtVXBMa2c/od6/public/values?alt=json', got_json)

if Meteor.isClient
  installApp = () ->
    if navigator?.mozApps?.checkInstalled and navigator?.mozApps?.install
      install_request = navigator.mozApps.install("http://viennajs.meteor.com/manifest.webapp")
      install_request.onerror = -> alert('Hey sorry, install didn\'t work ...')
    else
      alert('Could not install the ViennaJS App! Your platform does not support awesome FirefoxOS apps!')

  Template.appbar.events =
    'click #install': -> installApp()

  Template.flipbox.events = 
    'click #flip': -> 
      $('#flip')[0].toggle()
      fetchGoogleSpreadsheetAndSetData()

  Template.flipbox.created = ->
    Session.set('headline', "Next ViennaJS Meetup:")
    Session.set('cta', 'Prepare your minitalks!')
    fetchGoogleSpreadsheetAndSetData()

    Meteor.setInterval((->
      set_new_howlong()
      ), 100)

  Template.card_two.howlong = ->
    return Session.get('howlong')

  Template.card_two.readable_date = ->
    return Session.get('readable_date')

  Template.card_two.headline = ->
    h = Session.get('headline')
    regex = new RegExp('(viennajs)', 'gi')
    h.replace( regex, "<a href='http://www.viennajs.org/' target='_blank'>$1</a>" )

  Template.card_two.cta = ->
    Session.get('cta')  