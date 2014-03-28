Car2Go Vizualization
====================
Which questions can we answer:
1. Let's start with a very simple one – how many cars are available in the city depending on the time of the day
2.


Car2Go Cloudant Queries
====================

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

1. By minute and for Vancouver:
```
https://dybskiy.cloudant.com/car2go-march/_design/stats/_view/byCity?group_level=6&reduce=true&startkey=[%22Vancouver%22]&endkey=[%22Washington%20DC%22]
```
