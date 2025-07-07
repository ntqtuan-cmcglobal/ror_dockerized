# README

This is an example repository for working with rails and postgres, and setting them up using docker-compose.

To run this app, do the following.

1. Install docker
1. Run `docker-compose up`
1. This would run the web service in a container and postgres in a container.
1. Would look something like this.
   ![alt text](blog_images/docker_compose.png)

1. This would take a while the first time.
1. Now we need to create db before we can go any further. For this we'll connect to the docker container. 6. In another terminal run `docker ps` 7. ![alt text](blog_images/docker_ps.png) 8. Copy the container id for web, and connect to container by running this command. `docker exec -it 1597728759c0 sh` 9. You'll be connected to the docker container. 10. Run `rake db:create && rake db:migrate`
1. Go to [http://localhost:3000/](http://localhost:3000/) and see if everything is working.
1. Run all your rails commands in the container itself.
1. Try running `rails g scaffold blog title:string body:string`
1. Go to [http://localhost:3000/blogs](http://localhost:3000/blogs) and see if everything works.
1.
