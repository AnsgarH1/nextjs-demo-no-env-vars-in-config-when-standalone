# Next.js environment vars issue

This repo demonstrates an issue with Next.js when trying to build and run a multi-environment  Docker Image using environment variables inside next.config.js. The specific issue stems from using environment variables inside the rewrite config, but likely applies to using environment variables inside next.config.js in general.

## Assumptions

- Next.js is using the 'standalone' mode to run inside Docker
- The docker image should be usable for multiple environments (dev, staging, prod):
- Client-side environment variables (prefixed with NEXT_PUBLIC) can't be used, because they are evaluated during build.
- All necessary configuration that is normally provided by client-side environment variables is replaced by server-side functionality (redirects/rewrites, server actions, etc).
- There is no access to the specific environment variables for all stages beforehand, because they are injected into the dev / staging / prod environment by Kubernetes.

## The problem

During the build, the next.config.js gets serialized and an error is thrown if used environment variables are not provided.

## Expected behavior

During build, (server) environment variables are not required. An Error gets only thrown if client side environment variables are used and not provided.

## The workaround:

- Inside next.config.js, environment variables are only set during development, when building the Next.js app, they are replaced by a placeholder. 
- The entrypoint of the docker image is not the start of the node server, but a bash script entrypoint.sh
- The entrypoint script replaces the placeholders in all known files where they occur with the linux envsubst command.


## How to reproduce

The main branch contains the working solution with the workaround. Check out the "expected-behaviour" branch if you want to reproduce the broken state.

You will need to copy the .env.example file to .env.local. This environment file also was added to the dockerignore, to exclude it from the docker build step, which should also be the case inside a CI/CD environment. 

You can run the project locally with:
- `pnpm install`
- `pnpm dev`

Or to run with docker:
- `pnpm docker:build` and
- `pnpm docker:run`
  
The running docker container should get mapped to [port 4000](http://localhost:4000) (to be reaally sure, that you don't accidentally open the parallel running next dev server inside the terminal you left open)

The docker run job also parses the env file again, expose the variables to the container environment. Checkout the actual scripts inside the [package.json](package.json)

Changes are made to following files:

### [next.config.js](next.config.mjs)

environment variables get replaced during build. 

```js
process.env.NODE_ENV !== "production"
        ? `https://${process.env.IMGIX_URL}/:path*`
        : `https://$IMGIX_URL/:path*`, 
```

###  [dockerfile](dockerfile)

- the envsubst package gets added to the container
- the entrypoint.sh Script is used as the entrypoint instead of starting the node.js server directly

### [entrypoint.sh](entrypoint.sh)

- The placeholder environment variables are replaced with the correct values from the environment
- Also add some pretty logging statements which changes where made to the files, to make sure everything has worked
