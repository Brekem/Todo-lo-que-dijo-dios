package com.brekem.todo_lo_que_dios_dijo

import com.ryanheise.audioservice.AudioServiceActivity

// La actividad comparte el motor de Flutter con el servicio de reproducción,
// para que la lectura siga con la pantalla apagada o en otra app.
class MainActivity : AudioServiceActivity()
