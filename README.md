# TalosHub

AI hub. Powered by Azure cognitive services. The PWA lets you share the custom vision AI models and chatbots you've built with the Azure platform. 

Usage is very intuitive: https://algure.github.io/RoboHub/

## Uploading Your Model

You're welcome to upload your Azure AI services. Just follow these steps.

1) Launch the PWA on any browser https://algure.github.io/RoboHub/
2) Click the add icon on the toolbar.

  ![robo1](https://user-images.githubusercontent.com/37802577/122497058-aef95100-cfe4-11eb-9ba0-6cff133f5270.png)
  
3) Enter your email and password (something really simple) and then click on signup. Enter the same details and sign if you ever need to upload more of your work.

  ![robo2](https://user-images.githubusercontent.com/37802577/122497650-a5bcb400-cfe5-11eb-864a-eac120814dc3.png)
  
4) You may change your name by clicking on the 'no name' text (if you find it annoying 😐).
5) To add an AI, simply click on the 'Add AI' button and fill out all the details the labels indicate.

  ![robo5](https://user-images.githubusercontent.com/37802577/122499238-75c2e000-cfe8-11eb-94d4-eac336acb072.png)

Chatbots.
- You'll need to enter a name and description for your chatbot.
- To get the endpoint, head over to your QnA maker on the Azure portal.
- The details of the chatbot can be gotten when your chatbot is published.

  ![vis4](https://user-images.githubusercontent.com/37802577/122506457-4e730f80-cff6-11eb-95d9-73bc049b7516.png)
  
- The host field should be filled with the text highlighted in purple.
- The link field should be filled with the text highlighted in purple.
- The endpoint key field should be filled with the text highlighted in green.

Custom Vision Models.
You can also publish your models with Custom Vision and share on the hub. Head over to the Custom Vision platform, sign in and follow these steps.
- Click on the project you'd like to share.

  ![vis1](https://user-images.githubusercontent.com/37802577/122501282-46ae6d80-cfec-11eb-8fe1-7da4cf66a7c1.png)
  
- Head over to the Performance tab and click on `Prediction URL` to reveal your API details. If the `Prediction URL` button is gray (inactive), you'll have to publish your     model first.

  ![vis3](https://user-images.githubusercontent.com/37802577/122502318-516a0200-cfee-11eb-84cd-515f8febc44d.png)
  
- On the TalosHub app, head over to the Add AI page and select the category as `Computer Vision`.
- In the Endpoint field, input the image file API endpoint.
- n the Endpoint key, input the Prediction-Key in the field highlighted above.
- Save your inputs and check them out when you refresh the home page.

You can change any detail of your AI from the portal by clicking on it from the list.

If you'd like to build AI services on Azure, checkout the AI fundamentals course outline... https://docs.microsoft.com/en-us/learn/certifications/exams/ai-900

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
