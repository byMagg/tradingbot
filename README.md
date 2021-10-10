App móvil basada en Flutter haciendo uso de API Coinbase, estos datos en formato JSON se procesan y se
adaptan a los distintos objetos en la aplicación según se van necesitando, para la actualización de
la información se usan los llamados Streams, los cuales son unos "canales" por los que se transmiten
los datos y estos se actualizaran repetidamente con un tiempo previamente establecido.
En el caso de necesitar una actualización en tiempo real se hace uso de WebSockets permitiendo
así actualizar los datos al instante en que se modifican en el exchange, simplemente estableces
una "subscripción" a uno de los canales que deseeas escuchar e irán llegando snapshots con la
información.

https://user-images.githubusercontent.com/44727429/136705412-5f2dfc3f-5a92-458f-b64f-33a7f50ab1eb.mp4

