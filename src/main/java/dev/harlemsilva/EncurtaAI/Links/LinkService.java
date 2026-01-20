package dev.harlemsilva.EncurtaAI.Links;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class LinkService {
    private final LinkRepository linkRepository;

    public LinkService(LinkRepository linkRepository){
        this.linkRepository = linkRepository;
    }

    // Gerar uma url aleatória (tamanho fixo 6)
//    public String generateRandomUrl() {
//        String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
//        StringBuilder randomUrl = new StringBuilder();
//        for (int i = 0; i < 6; i++) {
//            int index = (int) (Math.random() * characters.length());
//            randomUrl.append(characters.charAt(index));
//        }
//        return randomUrl.toString();
//    }

    // Gerar uma url aleatória (tamanho variável entre 5 e 10)
    // TODO: REFATORAR PARA INCLUIR PARTE DA URL ORIGINAL NO NOSSO ALGORITIMO DE GERACAO DE URLS
    public String gerarUrlAleatoria() {
        return RandomStringUtils.randomAlphanumeric(5, 10);
    }

    public Link encurtarUrl(String urlOriginal) {
        Link link = new Link();
        link.setUrlLong(urlOriginal);
        link.setUrlEncurtada(gerarUrlAleatoria());
        link.setUrlCriadaEm(LocalDateTime.now());
        link.setUrlQrCode("QR CODE INDISPONÍVEL NO MOMENTO"); // Placeholder para QR Code
        // Salvar no banco
        return linkRepository.save(link);
    }

    public Link obterUrlOriginal(String urlEncurtada) {
        try {
            return linkRepository.findByUrlEncurtada(urlEncurtada);
        } catch (Exception erro) {
            throw new RuntimeException("Url nao existe nos nossos registros", erro);
        }
    }
}
