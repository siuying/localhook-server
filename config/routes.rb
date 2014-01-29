# Check out https://github.com/joshbuddy/http_router for more information on HttpRouter
HttpRouter.new do
  add('/').to(HomeAction)
  add('/_localhook').to(HookAction)
  post('/*').to(PostAction)
end
