const express = require('express');
const app = express();
app.use(express.json());

const users = [];

app.get('/users', (req, res) => {
  res.json(users);
});

app.get('/users/:id', (req, res) => {
  const userId = parseInt(req.params.id);
  const user = users.find(u => u.id === userId);

  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  res.json(user);
});

app.post('/users', (req, res) => {
  const { id, name } = req.body;

  if (typeof id !== 'number' || !name) {
    return res.status(400).json({ error: 'Invalid user data' });
  }

  // Check for duplicates
  const exists = users.some(u => u.id === id);
  if (exists) {
    return res.status(409).json({ error: 'User already exists' });
  }

  users.push({ id, name });
  res.status(201).json({ message: 'User added' });
});

app.listen(5001, () => console.log('User service running on port 5001'));
