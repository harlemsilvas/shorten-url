package dev.harlemsilva.EncurtaAI.Links;

import org.springframework.data.jpa.repository.JpaRepository;

public interface LinkRepository extends JpaRepository<Link, Long> {

    // Corrigido: buscar por urlEncurtada (campo existente na entidade Link)
    Link findByUrlEncurtada(String urlEncurtada);
}
