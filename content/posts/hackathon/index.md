---
date : '2025-01-24T00:19:06+01:00'
title : 'Hackapizza write-up - 2nd place and a lot of fun'
summary: "The write-up of my first Hackaton."
description: "The write-up of my first Hackaton."
toc: true
readTime: true
autonumber: false
math: false
tags: ["hackathon", "rag", "llm", "mongodb", "faiss", "python", "langchain", "langgraphs"]
showTags: false
---


In the 18th and 19th of January 2025, I participated in my first Hackathon, [HackaPizza](https://hackathon.datapizza.com/), organized by the amazing team of [DataPizza](https://www.datapizza.tech/). It was a 24-hours event, held in Milan, Italy, in a very iconic and fascinating location: the IBM Studios, in Piazza Gae Aulenti. 

![alt text](ibm.png  "IBM Studios, image from Wikipedia")


I was part of the team `4-omini` (very bad Italian joke), composed by me, Cristian, Andrea and Alessandro. There were 20 teams participating, each composed of 3 or 4 members, that had been chosen by the organizers among more than 600 applicants. We knew that the bar was high, but we were ready to give our best.


![alt text](4-omini.jpeg  "4-omini, happy and tired after 24 hours of grinding")


Going into the event, we only knew that the Hackathon would be about Generative AI, with topics like RAG and Agents being more likely, but of course we didn't know the exact challenge. Nonetheless, we didn't really care, we just wanted to learn things, build something and enjoy the experience. Which we did!

In this write up, I will go through the highlights of the event as seen from our perspective. I will talk about the things that worked and those that didn't, as well as the reasons behind our choices and the way we got to the final solution. If you are brave enough, you can follow the story by looking at the commit history of our [GitHub repository](https://github.com/GiovanniGiacometti/hackathon). Please don't judge the quality of our code, sleep deprivation can make you do weird things.

## 12:30 - So it begins

First things first: the challenge. After a brief introduction by the organizers, the cage was opened and we were given the text of the challenge. Here is a short summary, written by Claude 3.5:

```
"AI Challenge: Building an Intergalactic Restaurant Recommender"

Set in a sci-fi universe where interstellar dining is the norm, 
this challenge tasks developers with creating an AI assistant for 
cosmic food recommendations. The system needs to process natural 
language queries and suggest dishes from across the galaxy 
while respecting alien dietary restrictions 
and galactic food regulations.

Key technical requirements:
- Natural language query processing
- Multi-source data integration (menus, regulations, reviews)
- Generative AI implementation (RAG and AI Agents)
- Compliance verification with food safety standards

Performance evaluation uses Jaccard Similarity 
against reference solutions, measuring both accuracy 
and innovation in approach.

Think of it as Yelp meets Star Wars, powered by AI.
```

The summary is accurate, as the challenge was pretty straightforward. You might be thinking: "Well, that's a RAG". And you would be right. However, there were some complications that would make a naive RAG implementation miserably fail:

- Documents were in Italian and all the members of this imaginary universe had very weird names, barely making any sense in Italian ("Sinfonia Cosmica all'Alba di Fenice", "Eclissi del Drago nell'Abbraccio del Kraken", ...). Standard LLMs would struggle to understand these entities if not properly instructed.
- The documents were not in a huge amount (around 60) but they were of mixed types: Pdfs, Html, Word, even a CSV. This surely complicated the data preprocessing phase.
- The content of the documents was complex: they contained a lot of noise, they were not consistent with each other and most of them was not well structured. Some pages were blurred and others filled with unknown characters. Lots of information was spread across several documents, making it hard to retrieve necessary data to answer the queries. Additionally, the author of the challenge deliberately introduced typos and misleading information in the documents, making it even harder to extract the correct information. Yes, they were a mess.

Another relevant aspect of the challenge were the types of queries that our system was supposed to face. The questions provided were very specific and expected precise answers. This differs from usual RAG applications, where questions are more open-ended and the model can generate a wide range of (somewhat correct) answers. This meant that our retrieval systems should have both high precision and high recall, since likely all documents related to the query, even if not directly answering it, would be needed to answer it correctly. 

For instance, a query like "Quali piatti, preparati in un ristorante su Asgard, richiedono la licenza LTK non base e utilizzano Carne di Xenodonte?" would need to retrieve the menu of all restaurants on Asgard, filter the dishes that include Xenodonte meat and then compare the resulting options with the requirements of the LTK license.

## 13:00 - The first steps

The first hour of the challenge was basically only brainstorming. We knew that a precise and well-though plan was necessary. 

We first designed our pipeline, which would be composed of 2 main steps:
- **Ingestion**: this step is run only once and consists in parsing all documents into chunks of text and storing them in a vector database. We decided to apply semantic splitting, based on the structures of the documents, so that each chunk would contain a coherent piece of information. We chose [ChromaDB](https://www.trychroma.com/) as our vector database.
- **RAG**: the core of the system. This step receives the query as input, retrieves the relevant chunks from the database and then generates the answer using an LLM. Since the final response was supposed to be the list of ids of the dishes answering the questions, an additional component would be needed to translate the response of the LLM into the correct format. We chose [LangGraph](https://www.langchain.com/langgraph) as the framework for our pipeline. 


As previously explained, we soon realized that a retrieval system based on similarity between embeddings would not be enough. We decided to opt for an hybrid approach based on metadata. The process would work as follows:

1) During the ingestion phase, we would ask an LLM to extract the metadata from each chunk of text. To make sure every chunk was correctly encapsulated in the context of the overall document, we also added to each chunk some metadata extracted from the document as a whole. For instance, in the chunk related to a specific dish of a restaurant, we would add the metadata of the restaurant itself. All these metadata would then be stored in the vector database alongside the text.

2) During the RAG phase, we would first ask an LLM to extract the relevant metadata from the query. Then, we would retrieve the chunks tagged with those metadata from the database and then apply the cosine similarity to retain only the most similar chunks (this is supported out of the box by the [LangChain integration](https://python.langchain.com/docs/integrations/vectorstores/chroma/#query-by-turning-into-retriever)). Finally, we would pass the resulting chunks to the LLM to generate the answer.

At that point, we were ready to start coding. The plan was to build a functioning pipeline as soon as possible, so that we could reiterate on it and optimize it later. Well, that's easier said than done.


# 21:00 - At least it runs

After *many* hours of coding, almost all of the components were ready. In the meantime, other teams had already submitted their solutions. One team scored an encouraging 58%, well above the baseline provided by the organizers (38%). We were not worried, but indeed that was the realization that the competition was fierce.

We assembled the pipeline and ran it for the first time. The results were ... missing. The model was not answering at all, the `dishes` field of its [structured output](https://python.langchain.com/docs/concepts/structured_outputs/) was always empty. We were puzzled, but the behaviour was so weird that we knew there would be a reason for that. We leveraged [Langsmith](https://www.langchain.com/langsmith) to analyze each step of the pipeline and soon realized that the retrieval system was not working properly. The context provided to the LLM was alwasy missing the relevant information. Why?

There were several problems within our metadata extraction process:

- We were not extracting enough metadata. Mainly, we were not extracting information related to the ingredients of the dishes, which were involved in most of the questions we had to answer.

- Metadata were not always consistent: the LLM extracting metadata from the query would sometimes provide metadata that were not present in the database, both due to typos and hallucinations. Since we were filtering metadata on exact matches, this would lead to no results being returned.

- Metadata were sometimes missing: the LLM would just miss some of them, leading to the same problem as above.

The first point was easy to fix: add another step in the Ingestion phase to extract the additional metadata. The second point and third points were trickier: how do you make sure that the LLM doesn't come up with a new metadata? How do you ensure that it doesn't miss any information?

We adopted the following approach: whenever asking the LLM to extract metadata, both in the ingestion and in the RAG phase, we would also provide it with all the metadata extracted up to that point. Moreover, we explicitly prompted the LLM to use an existing metadata whenever it would find a similar but not identical one. This would help the metadata set to be consistent. We leveraged prompt engineering also to foster the LLM to avoid missing metadata, by instructing it to look for "weird" names with capital letters. You can take a look at the final version of the prompt [here](https://github.com/GiovanniGiacometti/hackathon/blob/main/hackathon/graph/prompts.py#L218).

Tiredness was starting to show up, but it was time to go back coding.

# 05:00 - The first (disastrous) submission


Several coffees and Redbulls later, we had implemented all the changes and were ready to 


(We submit the first version, miserable results. We need to optimize) We decide to split.



In addition to these points, we noticed that sometimes, even when the metadata were extracted correctly, the chunks provided to the LLM were not so helpful. This would happen in cases where the metadata filtering was too large, and the retrieved context would only be due to the cosine similarity, which was definitely not enough to provide relevant information.


# 08:30 -  Winter is coming

(Crazy scene, we submit at the same time)


# 12:30 - The End

(The last 3 hours were a crazy rush: )