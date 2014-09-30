var io = require('socket.io').listen(5001);

io.on('connection', function(socket){
  console.log('a user connected', socket);

  socket.on('disconnect', function (d) {
    console.log('user disconnected', d);
  });

  socket.on('updateSeries', function (data) {
    console.log(data)
    console.log("KEY", data.key)
    socket.broadcast.emit('updateSeries', data);
  });
});
