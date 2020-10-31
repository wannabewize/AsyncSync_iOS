const express = require('express');
const app = express();

app.listen(3000);

app.get('/', (req, res) => {
    setTimeout(() => {
        res.send({msg: 'ok'});
    }, 3000);
});