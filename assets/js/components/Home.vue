<template>
  <div>
    <h1>Home</h1>

    <section>
      <h2>Subscribe to a new feed</h2>

      <form @submit="subscribe">
        <label for="url">Enter the RSS feed URL:</label>
        <input id="url" name="url" v-model="url" />
        <button type="submit">Subscribe</button>
      </form>
    </section>
  </div>
</template>

<script>
export default {
  data() {
    return {
      url: "",
    };
  },
  methods: {
    subscribe(e) {
      e.preventDefault();

      const payload = {
        url: this.url,
      };
      fetch("/subscription", {
        method: "POST",
        body: JSON.stringify(payload),
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-TOKEN": document.head.querySelector('meta[name="csrf-token"]')
            .content,
        },
      })
        .then((resp) => resp.json())
        .then((data) => {
          console.log(data);
        });
    },
  },
};
</script>
