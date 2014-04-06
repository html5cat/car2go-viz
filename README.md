Car2Go Vizualizations
====================

I'm a fan of car-sharing and Car2Go in particular ([it has an API!](https://code.google.com/p/car2go/)). A lot of my friends use it and I think it would be nice to visualize movements over extended periods of time to spot interesting patterns.


Which questions can we answer:

1. Let's start with a very simple one – how many cars are available in the city depending on the time of the day
2. What's the likelyhood of catching a car at this particular location at this time of the day
3. {{yourQuestionHere}}


Data
====================

I have a couple of datasets hosted on [Cloudant](https://cloudant.com/) that you can play with:

1. (Dec. 24th 2013 - Feb. 2014) all cities, every 5 min – [http://dybskiy.cloudant.com/car2go/](http://dybskiy.cloudant.com/car2go/) (50 Gb)
2. (March 2014) all cities, every 2.4 hours (10 snaps per day) – [http://dybskiy.cloudant.com/car2go-march/](http://dybskiy.cloudant.com/car2go-march/) (420 Mb)


Aaron has a nice archive for Portland: [http://aaronparecki.com/car2go](http://aaronparecki.com/car2go)



Car2Go Cloudant Queries
====================
1.
Map function:
```

function(doc) {
  var date = new Date(Date.parse(doc.timestamp));

  emit([doc.location,
        date.getFullYear(), date.getMonth(), date.getDate(),
        date.getHours(), date.getMinutes()],
        doc.placemarks.length);
}

```

2.
emit  location, vin, date

3. have custom reduce emitting path as geojson


## Queries
1. By minute and for Vancouver:
```
https://dybskiy.cloudant.com/car2go-march/_design/stats/_view/byCity?group_level=6&reduce=true&startkey=[%22Vancouver%22]&endkey=[%22Washington%20DC%22]
```

Reference
============
Here's a fun project by Matt Sacks visualizing Car2Go Portland movements over last three days – [http://sacks.io/disposable-cars/](http://sacks.io/disposable-cars/)