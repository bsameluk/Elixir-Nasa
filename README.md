# NASA Flights Calculator

Phoenix LiveView application for calculating fuel requirements for interplanetary space missions. Built as a NASA contractor evaluation project, this app uses a backwards calculation algorithm with recursive "fuel for fuel" logic to accurately compute mission fuel needs.

## Tech Stack

- **Elixir:** 1.16.0
- **Erlang/OTP:** 26
- **Phoenix:** 1.8.1
- **Phoenix LiveView:** 1.1.0
- **Tailwind CSS + DaisyUI**

## Setup

```bash
# Generate secret key and create .env file
echo "SECRET_KEY_BASE=$(mix phx.gen.secret)" > .env
```

## Local Development

```bash
mix deps.get
mix phx.server
```

## Testing

```bash
# Run all tests
mix test
```

## Docker

```bash
docker-compose up
```

## AWS Deployment

```bash
# Setup
brew install awsebcli
eb init -p docker nasa-flights-calculator --region us-east-1
eb setenv SECRET_KEY_BASE=$(mix phx.gen.secret)

# Deploy
eb create nasa-calc-env
eb open

# Cleanup
eb terminate nasa-calc-env --force
```
