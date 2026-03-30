import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { GoogleGenerativeAI } from "@google/generative-ai";

dotenv.config();

const app = express();
const port = process.env.PORT || 3001;

// Configuração do Gemini
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || '');

app.use(cors());
app.use(express.json({ limit: '10mb' }));

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.post('/analyze', async (req, res) => {
  try {
    const { image } = req.body; // base64 image data

    if (!image) {
      return res.status(400).json({ error: 'Nenhuma imagem fornecida' });
    }

    // Remover o prefixo data:image/jpeg;base64, se existir
    const base64Data = image.replace(/^data:image\/\w+;base64,/, "");
    
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

    const prompt = "Você é o 'Olho Digital' de uma pessoa com deficiência visual. Descreva o que está nesta imagem de forma concisa, direta e útil para alguém que não pode ver. Foque em objetos principais, pessoas, textos visíveis e possíveis obstáculos ou perigos. Responda em Português do Brasil.";

    const result = await model.generateContent([
      prompt,
      {
        inlineData: {
          data: base64Data,
          mimeType: "image/jpeg"
        }
      }
    ]);

    const response = await result.response;
    const text = response.text();

    res.json({ description: text });
  } catch (error: any) {
    console.error('Erro ao processar imagem com Gemini:', error);
    res.status(500).json({ error: 'Erro ao analisar a imagem', details: error.message });
  }
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
