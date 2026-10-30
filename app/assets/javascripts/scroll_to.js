document.addEventListener('turbo:load', () => {
  const scrollTo = new URLSearchParams(window.location.search).get('st')
  if (scrollTo) {
    const element = document.getElementById(scrollTo)
    if (element) element.scrollIntoView()
  }
})
