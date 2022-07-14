   it "can copy answers json", js: true do
      first('.copyJson').click
      page.execute_script('
        setTimeout(async () => {
          const text = await navigator.clipboard.readText();
          alert(text)
          console.log(text);
        }, 1000);
      ')

      sleep 100

    end