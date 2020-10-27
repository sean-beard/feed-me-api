<template>
  <h1>Home</h1>
</template>

<script>
export default {
  created() {
    const payload = {
      url: "https://cprss.s3.amazonaws.com/frontendfoc.us.xml",
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
};
</script>
