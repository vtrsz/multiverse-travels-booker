# Multiverse Travels Book

## Installation

1. #### Install Docker
   `sudo apt-get install docker* -y`
   ###### <a href="https://www.docker.com/get-started/"> to download to other platforms</a>

2. #### Configure .env file located at project root directory.
   ###### (Only necessary if you want to customize it)

3. #### Run container
   `sudo docker-compose up -d` \
   ###### Make sure you have permission to run

### Running tests
   #### On docker before application starts: 
   1. `RUN_TEST_BEFORE_APPLICATION=true` in .env file
   2. run `sudo docker-compose up -d`
   #### On ./runtest script (creates container and removes it):
   1. Install curl `sudo apt-get install curl -y` (Needed to install Crystal)
   2. Download <a href="https://crystal-lang.org/install/">Crystal</a> (version 1.8.2)
   3. Run `sudo ./runtest` in root folder.


## Endpoints
### Example requests:

##### POST: /travel_plans 
###### Request body:
```json
{
    "travel_stops": [1, 2, 3]
}
```
###### content-type: "applicaton/json"

###### Response body:
```json
{
    "id": 1,
    "travel_stops": [
        1,
        2,
        3
    ]
}
```
###### content-type: "applicaton/json"

##### GET: /travel_plans
###### Response body:
```json
[
    {
        "id": 1,
        "travel_stops": [
            1,
            2,
            3
        ]
    }
]
```
###### content-type: "applicaton/json"

##### GET: /travel_plans?expand=true
###### Response body:
```json
[
    {
        "id": 1,
        "travel_stops": [
            {
                "id": 1,
                "name": "Earth (C-137)",
                "type": "Planet",
                "dimension": "Dimension C-137"
            },
            {
                "id": 2,
                "name": "Abadango",
                "type": "Cluster",
                "dimension": "unknown"
            },
            {
                "id": 3,
                "name": "Citadel of Ricks",
                "type": "Space station",
                "dimension": "unknown"
            }
        ]
    }
]
```
###### content-type: "applicaton/json"

##### GET: /travel_plans?optimize=true
###### Response body:
```json
[
    {
        "id": 1,
        "travel_stops": [
            1,
            2,
            3
        ]
    }
]
```
###### content-type: "applicaton/json"

##### GET: /travel_plans?optimize=true&expand=true
###### Response body:
```json
[
    {
        "id": 2,
        "travel_stops": [
            {
                "id": 19,
                "name": "Gromflom Prime",
                "type": "Planet",
                "dimension": "Replacement Dimension"
            },
            {
                "id": 9,
                "name": "Purge Planet",
                "type": "Planet",
                "dimension": "Replacement Dimension"
            },
            {
                "id": 2,
                "name": "Abadango",
                "type": "Cluster",
                "dimension": "unknown"
            },
            {
                "id": 11,
                "name": "Bepis 9",
                "type": "Planet",
                "dimension": "unknown"
            },
            {
                "id": 7,
                "name": "Immortality Field Resort",
                "type": "Resort",
                "dimension": "unknown"
            }
        ]
    }
]
```
###### content-type: "applicaton/json"

##### GET: /travel_plans/2
###### Response body:
```json
{
    "id": 2,
    "travel_stops": [
        2,
        7,
        19,
        9,
        11
    ]
}
```
###### content-type: "applicaton/json"

##### GET: /travel_plans/2?optimize=true
###### Response body:
```json
{
    "id": 2,
    "travel_stops": [
        19,
        9,
        2,
        11,
        7
    ]
}
```
###### content-type: "applicaton/json"

##### GET: /travel_plans/1?expanded=true
###### Response body:
```json
{
    "id": 1,
    "travel_stops": [
        {
            "id": 1,
            "name": "Earth (C-137)",
            "type": "Planet",
            "dimension": "Dimension C-137"
        },
        {
            "id": 2,
            "name": "Abadango",
            "type": "Cluster",
            "dimension": "unknown"
        },
        {
            "id": 3,
            "name": "Citadel of Ricks",
            "type": "Space station",
            "dimension": "unknown"
        }
    ]
}
```
###### content-type: "applicaton/json"

##### GET: /travel_plans/2?optimize=true&expanded=true
###### Response body:
```json
{
    "id": 2,
    "travel_stops": [
        {
            "id": 19,
            "name": "Gromflom Prime",
            "type": "Planet",
            "dimension": "Replacement Dimension"
        },
        {
            "id": 9,
            "name": "Purge Planet",
            "type": "Planet",
            "dimension": "Replacement Dimension"
        },
        {
            "id": 2,
            "name": "Abadango",
            "type": "Cluster",
            "dimension": "unknown"
        },
        {
            "id": 11,
            "name": "Bepis 9",
            "type": "Planet",
            "dimension": "unknown"
        },
        {
            "id": 7,
            "name": "Immortality Field Resort",
            "type": "Resort",
            "dimension": "unknown"
        }
    ]
}
```
###### content-type: "applicaton/json"

##### PUT: /travel_plans/1
###### Request body:
```json
{
    "travel_stops": [4, 5, 6]
}
```
###### content-type: "applicaton/json"

###### Response body:
```json
{
    "id": 1,
    "travel_stops": [
        4,
        5,
        6
    ]
}
```
###### content-type: "applicaton/json"

##### POST: /travel_plans/1/append
###### Request body:
```json
{
    "travel_stops": [9, 10, 11]
}
```
###### content-type: "applicaton/json"

###### Response body:
```json
{
    "id": 1,
    "travel_stops": [
        4,
        5,
        6,
        9,
        10,
        11
    ]
}
```
###### content-type: "applicaton/json"

##### DELETE: /travel_plans/1
###### 204 No Content

##### GET: /location/1/image
###### Response body:
```json
{
    "url": "https://static.wikia.nocookie.net/rickandmorty/images/f/fc/S2e5_Earth.png/revision/latest"
}
```
###### content-type: "applicaton/json"
###### (Unfortunately we do not have images of all locations)

### Do you want to make these requests? \
#### Download <a href="https://www.postman.com/downloads/">Postman</a> and import the file `multiverse-travels-booker.postman_collection.json` to use the collection with all endpoints.



## Contributors

- [Vitor Souza](https://github.com/vtrsz) - creator and maintainer
