st = Organization.create(name: 'Squareteam')
User.easy_new(name: 'john', email: 'john@squareteam.io', password: 'john').save
User.easy_new(name: 'albert', email: 'albert@squareteam.io', password: 'albert').save
u = User.easy_new(name: 'paul', email: 'paul@squareteam.io', password: 'paul').save
st.add_admin u
st.projects.create title: 'beta'
u.projects.create title: 'swcc'
u.projects.create title: 'spaas'
