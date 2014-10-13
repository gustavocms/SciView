var io = require('socket.io').listen(5001);

io.on('connection', function(socket){
  console.log('a user connected');

  socket.on('listenTo', function(key) {
    console.log("socket joining ", key);
    socket.join(key); // TODO error handling
  });

  socket.on('resetListeners', function() {
    socket.rooms = []; // TESTME
  });

  socket.on('disconnect', function(d) {
    console.log('user disconnected', d);
  });

  // key is of the form "viewState_123"
  socket.on('updateObservations', function(key, params) {
    console.log('updateObservations', key, params);
    socket.broadcast.to(key).emit('updateObservations', key, params);
  });

  socket.on('updateSeries', function(data) {
    console.log("KEY", data.key)
    socket.broadcast.to(data.key).emit('updateSeries', data);
  });
});
