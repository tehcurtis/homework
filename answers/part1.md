### My answer to part 1

Memcached is basically a key-value datastore that completely runs in memory and
is typically used to stored chunks of arbitrary data, like the results of an expensive database
query or a chunk of html that was expesnive to generate. The idea is that you store your expensive query results or
expensive html fragment in memcached so that when your application needs that data, it can just pull it out of memcached
instead of making the expensive operation.

As great as all that sounds, memcached storage is not persistent. If your memcached instance starts to get full, it will evict items
based on it's LRU (Least Recently Used, as in read or written) algorithm. This basically means that memcached will remove old, stale, unused data to make room for new data.

Now in a multi-node configuration, memcached will only store a chunk of data in one instance. There is no replication. Ideally, the client library
you use to access memcached will take of making sure your requests for a chunk of data actually get routed to the instance that the
chunk is stored on.
