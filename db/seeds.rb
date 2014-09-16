st = Organization.create(name: 'Squareteam')
User.easy_create(name: 'john', email: 'john@squareteam.io', password: 'john')
User.easy_create(name: 'albert', email: 'albert@squareteam.io', password: 'albert')
u = User.easy_create(name: 'paul', email: 'paul@squareteam.io', password: 'paul')
st.add_admin u
