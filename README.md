Car2Go: What do existing apps do now?
====================

The Car2Go app shows the following:

1. Locations of cars available at this moment of time

2. Gas/charge remaining in the car

3. {{Add your points here}}


Car2Go: What else may a user want?
====================

1. For my week/day planning I would like to see how car's availability changes during the day?

2. What's the likelyhood of catching a car at some particular location at some specific time of the day?

3. {{yourQuestionHere}}


Car2Go: What does the operator/owner want?
====================

No brainier, max profit! Even more specifically - max profit every next day.

Quick look into the problem gives a straight tech goal:

"Minimization of average park time for entire fleet for every next day".


Car2Go: What do we propose.
====================

Answer for users is straightforward: They may love an app that will visualize whatever is mentioned in the list in the beginning.

Owner may want, for example, to see how locations are ranked against car demand, and how this demand is changing throughout the day.

Also we believe in intelligent billing policy that will help to motivate moving cars to the locations with highest demand.


In order to achieve this goal the following tasks needs to be solved:
1) Rank locations against car demand
2)  . 




Tech question No 1: How to measure car demand?

Demand can be evaluated by the following measure/procedure:
1) Apply rect mesh (say 1km cell size) to entire area
2) Build a histogram "Number of cars vs park time"
3) Do simple statistics for diagrams for all locations (mean, mode)
4) Select the most suitable 
5) Apply it for test sample.
6) Test motivation algorithms to find those maximizing profit  
 

visualize movements over extended periods of time to spot interesting patterns.





Available Data
====================

There is [Car2Go API!](https://code.google.com/p/car2go/). 

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
