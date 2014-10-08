var io = require('socket.io').listen(5001);

io.on('connection', function(socket){
  console.log('a user connected');

  socket.on('watchSeries', function(seriesName) {
    console.log("socket joining ", seriesName, socket);
    socket.join(seriesName); // TODO error handling
  });

  socket.on('resetWatchers', function() {
    socket.rooms = []; // TESTME
  });

  socket.on('disconnect', function(d) {
    console.log('user disconnected', d);
  });

  socket.on('updateSeries', function(data) {
    console.log("KEY", data.key)
    socket.broadcast.to(data.key).emit('updateSeries', data);
  });
});
