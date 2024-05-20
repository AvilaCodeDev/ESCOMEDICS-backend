const express = require('express');
const cors = require('cors');

const { Router } = require('express');

const router = Router();

router.post(
    '/',
    function( req, res ){
        console.log("login");
    }
)

class Server {
    
    constructor() {
        this.app = express();
        this.port = process.env.PORT;
        this.usersPath = '/api/users';


        // Middlewares
        this.middlewares();

        //Rutas de mi aplicacion
        this.routes();
    }

    middlewares() {

        //CORS
        this.app.use( cors() );

        // Lectura y parseo del body
        this.app.use( express.json() );

        this.app.use( express.static( 'public' ) );

    }

    routes() {
        // this.app.use(this.usersPath, require('../routes/user'));
        this.app.use('/api/auth', require('../routes/auth'));
        this.app.use('/api/pacientes', require('../routes/pacientes'));
    }

    listen() {
        this.app.listen(this.port, () => {
            console.log('Servidor corriendo el el puerto', this.port );
        });
    }
}

module.exports = Server;