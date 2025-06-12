const express = require('express');
const app = express();
app.use(express.json());

const registrants = [];

app.get('/registrants', (req, res) => {
  res.json(registrants);
});

app.post('/register', (req, res) => {
  const { name } = req.body;

  if (!name || typeof name !== 'string') {
    return res.status(400).json({ error: 'Name is required' });
  }

  if (registrants.includes(name)) {
    return res.status(409).json({ error: 'Already registered' });
  }

  registrants.push(name);
  res.status(201).json({ message: `${name} registered successfully` });
});

app.listen(5001, () => console.log('Registrant service running on port 5001'));
