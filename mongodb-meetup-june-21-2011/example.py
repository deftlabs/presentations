#
# Copyright 2011, Deft Labs.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Some sample code of an architecture which had issues.
#

import datetime
import hashlib

# Make sure pymongo is installed
try:
    import pymongo
except:
    sys.exit('ERROR - pymongo not installed - see: http://api.mongodb.org/python/ - run: sudo easy_install pymongo')

# Verify the version of pymongo is kosher
pyv = pymongo.version
pyv = pyv.partition( "+" )[0]
if map(int, pyv.split('.')) < [1,9]:
    sys.exit('ERROR - this example requires pymongo 1.9 or higher: sudo easy_install -U pymongo')

#
mongo = pymongo.Connection('localhost', 27017)
testDb = mongo.test

# Drop the meetupExample collection
testDb.drop_collection('meetupExample')

# Increment the count. This should look like the following when run:
"""
{
    "_id" : "20110621-bits-mem-1499f25476f6e905ca13a6f6f9e97b32",
    "d" : "20110621",
    "dy" : {
        "n" : 10,
        "t" : NumberLong(10)
    },
    "g" : "mem",
    "hy" : {
        "20" : {
            "n" : 10,
            "t" : NumberLong(10)
        }
    },
    "i" : "bits",
    "mn" : {
        "1200" : {
            "n" : 10,
            "t" : NumberLong(10)
        }
    }
}
"""
for idx in range(0, 10):

    query = { "_id": "20110621-bits-mem-1499f25476f6e905ca13a6f6f9e97b32" }

    toSet = { "g": "mem", "i": "bits", "d": "20110621" }

    toInc = { "dy.t": long(1), "dy.n": 1, "hy.20.t": long(1), "hy.20.n": 1, "mn.1200.t" : long(1), "mn.1200.n": 1 }

    testDb.meetupExample.update(query, { "$set" : toSet, "$inc": toInc }, upsert=True)

# Showcase next day (empty) doc creation.
currentHour = 0
statDocs = { }
minuteStatDocs =  { }
statDocs['00'] = minuteStatDocs

for minute in range(0, 1440):

    minuteHour = minute / 60

    if minuteHour is not currentHour:
        currentHour = minuteHour
        minuteStatDocs = { }
        statDocs["%02d" % minuteHour] = minuteStatDocs

    minuteStatDocs["%04d" % minute] = { "n" : 0, "t": long(0) }

testDb.meetupExample.insert({ "_id": "20110622-bits-mem-1499f25476f6e905ca13a6f6f9e97b32", "d" : "20110622", "g": "mem", "i": "bits", "mn": statDocs })

