# `email` 💌

[![Build Status](https://img.shields.io/travis/dwyl/email/master.svg?style=flat-square)](https://travis-ci.org/dwyl/email)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/email/master.svg?style=flat-square)](http://codecov.io/github/dwyl/email?branch=master)
[![HitCount](http://hits.dwyl.com/dwyl/email.svg)](http://hits.dwyl.com/dwyl/email)

## Why? 🤷‍

We needed a way to keep track of email in our App.
To know precise stats for deliverability, click-through and bounce rates
in real-time so that we can monitor the "health" of our
[feedback loop](https://en.wikipedia.org/wiki/Feedback).
This is our quest to do that.



## What? 💭

An email dashboard for our App.

## Who? 👤

Right now we are building this App _just_ for our own (_internal_) use. <br />
As with ***everything*** we do,
it's **Open Source** so others can learn from it.


## How?

### 0. Create a New Phoenix App


In your terminal, run the following mix command:

```elixir
mix phx.new app
```

That will create a few files.
e.g: [github.com/dwyl/email/commit/1c999be](https://github.com/dwyl/email/commit/1c999be3fff75e42fcb6e62e1f2a152764ce3b74)

Follow the instructions in the terminal to download all the dependencies.




### 1. Copy over the Migration Files from the MVP 📋

In order to speed up our development of the **`email`** App,
we are _only_ going to create _one_ schema/table; **`sent`** (_see: step 2_).
Since our app will refer to email addresses,

See: [github.com/dwyl/email/commit/bcafb2f](https://github.com/dwyl/email/commit/bcafb2fbd92782b1e166305428c5211690374b2e)

#### _Why_ reuse migrations?

Our objective is to be able to run the **`email`** App in several ways:
1. **Independently** from any "main" App.
So the **`email`** dashboard can be 100% anonymised
and we just display _aggregate_ stats for all email being sent/received.
2. **Inside** the "main" App.
If we don't want to have to deploy _separate_ Apps,
we can simply include the **`email`** functionality within a "main" App.
3. **Umbrella App** where the **`email`** App is run as a "child" to the "main".

By reusing the **migration** files from our "main" App,
(_the files need to have the **exact same name** and contents_),
we maintain full flexibility to run our **`email`** App in any way.
This is because if we run the migrations against the "main" PostgreSQL DB,
the migrations with those timestamps will _already_ exist
in the **`migrations`** table; so no change will be required.
However


### 2. Create the `sent` Schema/Table

In order to store the data on the emails that have been sent,
we need to create the **`sent`** schema:

```elixir
mix phx.gen.html Ctx Sent sent message_id:string person_id:references:people request_id:string status_id:references:status template:string
```

When you run this command in your terminal,
you should see the following output
showing all the files that were created:

```
* creating lib/app_web/controllers/sent_controller.ex
* creating lib/app_web/templates/sent/edit.html.eex
* creating lib/app_web/templates/sent/form.html.eex
* creating lib/app_web/templates/sent/index.html.eex
* creating lib/app_web/templates/sent/new.html.eex
* creating lib/app_web/templates/sent/show.html.eex
* creating lib/app_web/views/sent_view.ex
* creating test/app_web/controllers/sent_controller_test.exs
* creating lib/app/ctx/sent.ex
* creating priv/repo/migrations/20200224224024_create_sent.exs
* creating lib/app/ctx.ex
* injecting lib/app/ctx.ex
* creating test/app/ctx_test.exs
* injecting test/app/ctx_test.exs

Add the resource to your browser scope in lib/app_web/router.ex:

    resources "/sent", SentController

Remember to update your repository by running migrations:

$ mix ecto.migrate
```

We will follow these instructions in the next steps!

#### Why So Many Files?

We are not going to do anything with the



#### What are the `message_id` and `request_id` fields for?

In case you are wondering what the **`message_id`** and **`request_id`** fields
in the **`sent`** schema are for.
The **`message_id`** is,
as you would expect,
the _Globally Unique_ ID (GUID)
for the message in the AWS SES system.
We need to keep track of this ID because
all SNS notifications will reference it.
So if we receive a "delivered" or "bounce" SNS notification,
we need to match it up to the original **`message_id`**
so that our data reflects the **`status`** of the message.

The [`aws-ses-lambda`](https://github.com/dwyl/aws-ses-lambda) function
returns a response in the following form:

```js
{
  MessageId: '010201707927184a-e45eb814-3721-43cb-ac70-f527a9907055-000000',
  ResponseMetadata: {
    RequestId: 'd876bd28-4962-4eea-b7c4-17703b113279'
  }
}
```

Or when invoked from Elixir
see:
[github.com/dwyl/elixir-invoke-lambda-example](https://github.com/dwyl/elixir-invoke-lambda-example)
the response is:

```elixir
{:ok,
 %{
   "MessageId" => "010201703dd218c7-ae82fd07-9c08-4215-a4a9-4b723b98d8f3-000000",
   "ResponseMetadata" => %{
     "RequestId" => "def1b013-331e-4d10-848e-6f0dbd709434"
   }
 }}
```

We are storing `MessageId` as `message_id`
and `RequestId` as `request_id`.


### 3. Add the SentController Resources to `router.ex`

Open the
`lib/app_web/router.ex`
file
and locate the section that starts with
```elixir
scope "/", AppWeb do
```
Add the following line in that scope:

```elixir
resources "/sent", SentController
```

e.g: [/lib/app_web/router.ex#L20](https://github.com/dwyl/email/blob/db1abd0cc075d27b7cd2bfc37019fc33dd5d0585/lib/app_web/router.ex#L20)


### 4. Run the Migrations


In your terminal run the migrations command:

```elixir
mix ecto.migrate
```

You should expect to see outpout similar to the following:

```
23:15:48.568 [info]  == Running 20200224224024 App.Repo.Migrations.CreateSent.change/0 forward

23:15:48.569 [info]  create table sent

23:15:48.574 [info]  create index sent_person_id_index

23:15:48.575 [info]  create index sent_status_id_index

23:15:48.576 [info]  == Migrated 20200224224024 in 0.0s
```

#### Entity Relationship Diagram (ERD)

ERD after creating the **`sent`** table:

![erd-with-sent-table](https://user-images.githubusercontent.com/194400/75200073-b6944700-575c-11ea-97c9-a7b495395a05.png)


### Checkpoint: Run the App!

Just to get an idea for what the `/sent` page _currently_ looks like,
let's run the Phoenix App and view it in an browser:
In your terminal run:

```elixir
mix phx.server
```

Now visit








### 5.






<br />
<br />


### _Required_ Environment Variables

Running this app or its' tests on your local machine will require
that you set a few
[*environment variables*](https://github.com/dwyl/learn-environment-variables)

Using your terminal or text editor, create your `.env` file.  
Then *paste* this *sample* into your `.env` file:

```txt
JWT_SECRET=WhatEverYouWant
```


To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).







## Troubleshooting
